import Foundation
import OSSSpeechKit

@MainActor
protocol SpeechRecognitionSessionProviding: AnyObject {
    func continuousRecognitionEvents(
        locale: Locale,
        requestAuthorization: Bool
    ) async throws -> AsyncThrowingStream<OSSSpeechContinuousRecognitionEvent, Error>
    func pauseRecognition()
    func resumeRecognition() throws
    func finishRecognition()
    func cancelRecognition()
}

extension OSSSpeechEngine: SpeechRecognitionSessionProviding {}

@MainActor
final class RecordingSessionModel {
    private static let rowBreakThreshold: TimeInterval = 0.8

    private struct TranscriptChunk {
        let row: TranscriptRow
        let segmentCount: Int
    }

    struct TranscriptRow: Equatable {
        let timestamp: TimeInterval
        let text: String
    }

    enum Status: Equatable {
        case idle
        case recording
        case paused
        case stopped
    }

    let language: OSSLanguage
    private(set) var status: Status = .idle
    private(set) var rows: [TranscriptRow] = []
    private(set) var liveText = ""
    private(set) var liveTimestamp: TimeInterval?

    var onChange: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onStop: (() -> Void)?

    var elapsedTime: TimeInterval {
        accumulatedActiveTime + (activeStartedAt.map { now().timeIntervalSince($0) } ?? 0)
    }

    private let engine: SpeechRecognitionSessionProviding
    private let now: () -> Date
    private var recognitionTask: Task<Void, Never>?
    private var timer: Timer?
    private var silenceTimer: Timer?
    private var activeStartedAt: Date?
    private var accumulatedActiveTime: TimeInterval = 0
    private var consumedSegmentCount = 0
    private var latestSegmentCount = 0
    private var lastTranscriptSignature = ""
    private var didStop = false

    convenience init(language: OSSLanguage) {
        self.init(language: language, engine: OSSSpeechEngine())
    }

    init(
        language: OSSLanguage,
        engine: SpeechRecognitionSessionProviding,
        now: @escaping () -> Date = Date.init
    ) {
        self.language = language
        self.engine = engine
        self.now = now
    }

    deinit {
        recognitionTask?.cancel()
        timer?.invalidate()
        silenceTimer?.invalidate()
    }

    func start() {
        guard status == .idle else { return }
        recognitionTask = Task { [weak self] in
            guard let self else { return }
            do {
                let events = try await engine.continuousRecognitionEvents(
                    locale: language.locale,
                    requestAuthorization: true
                )
                guard !Task.isCancelled else { return }
                status = .recording
                activeStartedAt = now()
                startTimer()
                notifyChange()

                for try await event in events {
                    guard !Task.isCancelled else { return }
                    handle(event)
                }
            } catch is CancellationError {
                return
            } catch {
                fail(with: error)
            }
        }
    }

    func pause() {
        guard status == .recording else { return }
        finalizeLiveText()
        resetTranscriptTracking()
        accumulatedActiveTime = elapsedTime
        activeStartedAt = nil
        engine.pauseRecognition()
        status = .paused
        notifyChange()
    }

    func resume() {
        guard status == .paused else { return }
        do {
            try engine.resumeRecognition()
            liveText = ""
            liveTimestamp = nil
            activeStartedAt = now()
            status = .recording
            notifyChange()
        } catch {
            fail(with: error)
        }
    }

    func stop() {
        guard !didStop else { return }
        didStop = true
        if status == .recording {
            accumulatedActiveTime = elapsedTime
            activeStartedAt = nil
        }
        finalizeLiveText()
        resetTranscriptTracking()
        timer?.invalidate()
        timer = nil
        engine.finishRecognition()
        recognitionTask?.cancel()
        status = .stopped
        notifyChange()
        onStop?()
    }

    func cancel() {
        guard !didStop else { return }
        didStop = true
        timer?.invalidate()
        timer = nil
        resetTranscriptTracking()
        recognitionTask?.cancel()
        engine.cancelRecognition()
        status = .stopped
        notifyChange()
    }

    func refreshElapsedTime() {
        notifyChange()
    }

    func formattedTimestamp(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func handle(_ event: OSSSpeechContinuousRecognitionEvent) {
        switch event {
        case .transcript(let transcript):
            apply(transcript)
        case .availabilityChanged(let available):
            if !available {
                fail(with: OSSSpeechError.recognizerUnavailable)
            }
        case .paused:
            break
        case .resumed:
            break
        case .completed:
            completeFromEngine()
        case .cancelled:
            cancel()
        }
    }

    private func apply(_ transcript: OSSSpeechTranscript) {
        if transcript.segments.count < consumedSegmentCount {
            resetTranscriptTracking()
        }

        let remainingSegments = Array(transcript.segments.dropFirst(consumedSegmentCount))
        let chunks = transcriptChunks(
            from: remainingSegments,
            fallbackText: transcript.formattedText
        )
        let completedCount = transcript.isFinal ? chunks.count : max(0, chunks.count - 1)
        for chunk in chunks.prefix(completedCount) {
            rows.append(.init(
                timestamp: liveTimestamp ?? chunk.row.timestamp,
                text: chunk.row.text
            ))
            consumedSegmentCount += chunk.segmentCount
            liveText = ""
            liveTimestamp = nil
        }

        if transcript.isFinal {
            liveText = ""
            liveTimestamp = nil
            resetTranscriptTracking()
        } else if let liveChunk = chunks.last {
            if liveText.isEmpty {
                liveTimestamp = elapsedTime
            }
            liveText = liveChunk.row.text
            latestSegmentCount = transcript.segments.count
            scheduleSilenceBreakIfNeeded(for: transcript)
        }
        notifyChange()
    }

    private func finalizeLiveText() {
        let text = liveText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            liveText = ""
            liveTimestamp = nil
            return
        }
        rows.append(.init(timestamp: liveTimestamp ?? elapsedTime, text: text))
        liveText = ""
        liveTimestamp = nil
    }

    private func transcriptChunks(
        from segments: [OSSSpeechTranscriptSegment],
        fallbackText: String
    ) -> [TranscriptChunk] {
        guard !segments.isEmpty else {
            let text = fallbackText.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? [] : [
                .init(row: .init(timestamp: elapsedTime, text: text), segmentCount: 0)
            ]
        }

        var chunks: [TranscriptChunk] = []
        var chunkSegments: [OSSSpeechTranscriptSegment] = []

        for segment in segments {
            if let previous = chunkSegments.last {
                let gap = segment.timestamp - (previous.timestamp + previous.duration)
                if gap >= Self.rowBreakThreshold {
                    chunks.append(makeChunk(from: chunkSegments))
                    chunkSegments.removeAll(keepingCapacity: true)
                }
            }
            chunkSegments.append(segment)
        }

        if !chunkSegments.isEmpty {
            chunks.append(makeChunk(from: chunkSegments))
        }
        return chunks
    }

    private func makeChunk(from segments: [OSSSpeechTranscriptSegment]) -> TranscriptChunk {
        var text = segments.map(\.text).joined(separator: " ")
        for punctuation in [".", ",", "!", "?", ";", ":"] {
            text = text.replacingOccurrences(of: " \(punctuation)", with: punctuation)
        }
        return .init(
            row: .init(
                timestamp: segments.first?.timestamp ?? elapsedTime,
                text: text.trimmingCharacters(in: .whitespacesAndNewlines)
            ),
            segmentCount: segments.count
        )
    }

    private func scheduleSilenceBreakIfNeeded(for transcript: OSSSpeechTranscript) {
        let signature = transcript.segments
            .map { "\($0.timestamp):\($0.duration):\($0.text)" }
            .joined(separator: "|")
        guard signature != lastTranscriptSignature else { return }
        lastTranscriptSignature = signature
        silenceTimer?.invalidate()
        let timer = Timer(timeInterval: Self.rowBreakThreshold, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.handleSilenceBreak() }
        }
        RunLoop.main.add(timer, forMode: .common)
        silenceTimer = timer
    }

    private func handleSilenceBreak() {
        guard status == .recording, !liveText.isEmpty else { return }
        finalizeLiveText()
        consumedSegmentCount = latestSegmentCount
        silenceTimer = nil
        notifyChange()
    }

    private func resetTranscriptTracking() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        consumedSegmentCount = 0
        latestSegmentCount = 0
        lastTranscriptSignature = ""
    }

    private func completeFromEngine() {
        guard !didStop else { return }
        didStop = true
        finalizeLiveText()
        timer?.invalidate()
        timer = nil
        resetTranscriptTracking()
        status = .stopped
        notifyChange()
        onStop?()
    }

    private func fail(with error: Error) {
        guard !didStop else { return }
        didStop = true
        timer?.invalidate()
        timer = nil
        resetTranscriptTracking()
        status = .stopped
        engine.cancelRecognition()
        notifyChange()
        onError?(error)
    }

    private func startTimer() {
        timer?.invalidate()
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refreshElapsedTime() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func notifyChange() {
        onChange?()
    }
}
