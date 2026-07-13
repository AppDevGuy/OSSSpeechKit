import AVFoundation
import Foundation
import Speech

/// Typed failures emitted by the modern OSSSpeechKit API.
public enum OSSSpeechError: Error, LocalizedError {
    /// The provided speech text was empty or only whitespace.
    case emptyText

    /// No installed speech synthesis voice matched the requested locale.
    case voiceUnavailable(localeIdentifier: String)

    /// Speech recognition authorization was denied or unavailable.
    case speechAuthorizationDenied

    /// Microphone recording authorization was denied or unavailable.
    case microphoneAuthorizationDenied

    /// Speech recognition does not support the requested locale on this device.
    case recognitionLocaleUnsupported(String)

    /// The speech recognizer exists but is not currently available.
    case recognizerUnavailable

    /// AVFoundation could not configure or start the audio engine/session.
    case audioEngineFailure(underlying: Error?)

    /// A speech synthesis or recognition operation is already active.
    case operationInProgress

    public var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Speech text must not be empty."
        case .voiceUnavailable(let identifier):
            return "No installed voice is available for \(identifier)."
        case .speechAuthorizationDenied:
            return "Speech recognition permission was not granted."
        case .microphoneAuthorizationDenied:
            return "Microphone permission was not granted."
        case .recognitionLocaleUnsupported(let identifier):
            return "Speech recognition does not support \(identifier) on this device."
        case .recognizerUnavailable:
            return "The speech recognition service is currently unavailable."
        case .audioEngineFailure(let underlying):
            return underlying?.localizedDescription ?? "The audio engine could not start."
        case .operationInProgress:
            return "Another speech operation is already in progress."
        }
    }
}

/// Events from a live recognition session.
public enum OSSSpeechRecognitionEvent {
    /// Interim transcription text emitted before recognition completes.
    case partial(String)

    /// Final transcription text emitted when recognition completes.
    case completed(String)

    /// Availability updates reported by the underlying speech recognizer.
    case availabilityChanged(Bool)

    /// Recognition was cancelled before producing a final result.
    case cancelled
}

/// A word or phrase reported by Apple's speech recognizer.
public struct OSSSpeechTranscriptSegment: Equatable, Sendable {
    public let text: String
    public let timestamp: TimeInterval
    public let duration: TimeInterval
    public let confidence: Float

    public init(text: String, timestamp: TimeInterval, duration: TimeInterval, confidence: Float) {
        self.text = text
        self.timestamp = timestamp
        self.duration = duration
        self.confidence = confidence
    }
}

/// A timestamped snapshot of the recognizer's current transcription.
public struct OSSSpeechTranscript: Equatable, Sendable {
    public let formattedText: String
    public let segments: [OSSSpeechTranscriptSegment]
    public let isFinal: Bool

    public init(
        formattedText: String,
        segments: [OSSSpeechTranscriptSegment],
        isFinal: Bool
    ) {
        self.formattedText = formattedText
        self.segments = segments
        self.isFinal = isFinal
    }
}

/// Events from a continuous recognition session.
public enum OSSSpeechContinuousRecognitionEvent: Sendable {
    case transcript(OSSSpeechTranscript)
    case availabilityChanged(Bool)
    case paused
    case resumed
    case completed
    case cancelled
}

/// Instance-based, main-actor-isolated speech synthesis and recognition engine.
@MainActor
public final class OSSSpeechEngine: NSObject {
    /// Current high-level activity of the speech engine.
    public enum State: Equatable {
        /// The engine is not speaking or listening.
        case idle

        /// The engine is currently synthesizing speech.
        case speaking

        /// The engine is currently recording and recognizing speech.
        case listening

        /// A continuous recognition session exists, but microphone capture is paused.
        case paused
    }

    /// Current high-level activity of the engine.
    public private(set) var state: State = .idle

    /// Whether recognition should require on-device processing when supported.
    public var usesOnDeviceRecognition = false

    /// Task hint passed to the underlying speech recognizer.
    public var recognitionTaskHint: SFSpeechRecognitionTaskHint = .unspecified

    private let synthesizer: AVSpeechSynthesizer
    private let audioEngine: AVAudioEngine
    private let audioSession: AVAudioSession
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionContinuation: AsyncThrowingStream<OSSSpeechRecognitionEvent, Error>.Continuation?
    private var continuousRecognitionContinuation:
        AsyncThrowingStream<OSSSpeechContinuousRecognitionEvent, Error>.Continuation?
    private var activeRecognizer: SFSpeechRecognizer?
    private var isContinuousRecognition = false
    private var synthesisContinuation: CheckedContinuation<Void, Error>?
    private var sessionID: UUID?
    private var recognitionTaskID: UUID?
    private var continuousStartedAt: Date?
    private var accumulatedContinuousTime: TimeInterval = 0
    private var recognitionTaskOffset: TimeInterval = 0
    private var tapInstalled = false

    /// Creates a speech engine with its own synthesizer, audio engine, and audio session.
    public override init() {
        synthesizer = AVSpeechSynthesizer()
        audioEngine = AVAudioEngine()
        audioSession = .sharedInstance()
        super.init()
        synthesizer.delegate = self
    }

    /// Locales that the platform reports as available for speech recognition.
    public static var supportedRecognitionLocales: Set<Locale> {
        SFSpeechRecognizer.supportedLocales()
    }

    /// Requests speech recognition authorization and maps the native status.
    public func requestSpeechAuthorization() async -> OSSSpeechKitAuthorizationStatus {
        let nativeStatus: SFSpeechRecognizerAuthorizationStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        switch nativeStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .restricted: return .restricted
        case .authorized: return .authorized
        @unknown default: return .restricted
        }
    }

    /// Requests microphone recording authorization.
    public func requestMicrophoneAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission {
                continuation.resume(returning: $0)
            }
        }
    }

    /// Speaks plain text using a resolved AVFoundation voice.
    public func speak(
        _ text: String,
        voice: OSSVoiceConfiguration,
        configuration: OSSUtteranceConfiguration = .init()
    ) async throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OSSSpeechError.emptyText
        }
        let utterance = AVSpeechUtterance(string: text)
        try await speak(utterance, voice: voice, configuration: configuration)
    }

    /// Speaks attributed text using a resolved AVFoundation voice.
    public func speak(
        _ attributedText: NSAttributedString,
        voice: OSSVoiceConfiguration,
        configuration: OSSUtteranceConfiguration = .init()
    ) async throws {
        guard !attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OSSSpeechError.emptyText
        }
        let utterance = AVSpeechUtterance(attributedString: attributedText)
        try await speak(utterance, voice: voice, configuration: configuration)
    }

    private func speak(
        _ utterance: AVSpeechUtterance,
        voice: OSSVoiceConfiguration,
        configuration: OSSUtteranceConfiguration
    ) async throws {
        guard state == .idle else { throw OSSSpeechError.operationInProgress }
        guard let resolvedVoice = voice.resolve() else {
            throw OSSSpeechError.voiceUnavailable(localeIdentifier: voice.language.localeIdentifier)
        }
        try configureAudioSession(category: .playback)
        utterance.voice = resolvedVoice
        configuration.apply(to: utterance)
        state = .speaking
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                synthesisContinuation = continuation
                synthesizer.speak(utterance)
            }
        } onCancel: {
            Task { @MainActor [weak self] in self?.stopSpeaking() }
        }
    }

    /// Pauses the current utterance immediately when the engine is speaking.
    public func pauseSpeaking() {
        guard state == .speaking else { return }
        synthesizer.pauseSpeaking(at: .immediate)
    }

    /// Resumes a paused utterance.
    public func continueSpeaking() {
        guard synthesizer.isPaused else { return }
        synthesizer.continueSpeaking()
    }

    /// Stops the current utterance and finishes the synthesis operation.
    public func stopSpeaking() {
        guard state == .speaking else { return }
        if !synthesizer.stopSpeaking(at: .immediate) {
            finishSynthesis(throwing: CancellationError())
        }
    }

    /// Starts recognition and returns a stream that owns the recording session.
    /// Cancelling iteration tears down the audio tap and recognition task.
    public func recognitionEvents(
        locale: Locale,
        requestAuthorization: Bool = true
    ) async throws -> AsyncThrowingStream<OSSSpeechRecognitionEvent, Error> {
        guard state == .idle else { throw OSSSpeechError.operationInProgress }
        if requestAuthorization {
            guard await requestSpeechAuthorization() == .authorized else {
                throw OSSSpeechError.speechAuthorizationDenied
            }
            guard await requestMicrophoneAuthorization() else {
                throw OSSSpeechError.microphoneAuthorizationDenied
            }
        }
        try Task.checkCancellation()

        guard let supportedLocale = OSSLanguage.supportedRecognitionLocale(equivalentTo: locale) else {
            throw OSSSpeechError.recognitionLocaleUnsupported(locale.identifier)
        }
        guard let recognizer = SFSpeechRecognizer(locale: supportedLocale) else {
            throw OSSSpeechError.recognitionLocaleUnsupported(locale.identifier)
        }
        guard recognizer.isAvailable else { throw OSSSpeechError.recognizerUnavailable }
        recognizer.delegate = self

        let stream = AsyncThrowingStream<OSSSpeechRecognitionEvent, Error> { continuation in
            recognitionContinuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.cancelRecognition() }
            }
        }
        do {
            try startRecognition(using: recognizer, continuous: false)
        } catch {
            recognitionContinuation?.finish(throwing: error)
            recognitionContinuation = nil
            throw error
        }
        return stream
    }

    /// Cancels the active recognition session and tears down audio recording.
    public func cancelRecognition() {
        guard state == .listening || state == .paused || recognitionTask != nil else { return }
        recognitionContinuation?.yield(.cancelled)
        recognitionContinuation?.finish()
        continuousRecognitionContinuation?.yield(.cancelled)
        continuousRecognitionContinuation?.finish()
        tearDownRecognition(cancelTask: true)
    }

    /// Starts a long-lived session that continues across recognizer-finalized utterances.
    public func continuousRecognitionEvents(
        locale: Locale,
        requestAuthorization: Bool = true
    ) async throws -> AsyncThrowingStream<OSSSpeechContinuousRecognitionEvent, Error> {
        guard state == .idle else { throw OSSSpeechError.operationInProgress }
        if requestAuthorization {
            guard await requestSpeechAuthorization() == .authorized else {
                throw OSSSpeechError.speechAuthorizationDenied
            }
            guard await requestMicrophoneAuthorization() else {
                throw OSSSpeechError.microphoneAuthorizationDenied
            }
        }
        try Task.checkCancellation()

        guard let supportedLocale = OSSLanguage.supportedRecognitionLocale(equivalentTo: locale) else {
            throw OSSSpeechError.recognitionLocaleUnsupported(locale.identifier)
        }
        guard let recognizer = SFSpeechRecognizer(locale: supportedLocale) else {
            throw OSSSpeechError.recognitionLocaleUnsupported(locale.identifier)
        }
        guard recognizer.isAvailable else { throw OSSSpeechError.recognizerUnavailable }
        recognizer.delegate = self

        let stream = AsyncThrowingStream<OSSSpeechContinuousRecognitionEvent, Error> { continuation in
            continuousRecognitionContinuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.cancelRecognition() }
            }
        }
        do {
            try startRecognition(using: recognizer, continuous: true)
        } catch {
            continuousRecognitionContinuation?.finish(throwing: error)
            continuousRecognitionContinuation = nil
            throw error
        }
        return stream
    }

    /// Pauses microphone capture while retaining a continuous recognition session.
    public func pauseRecognition() {
        guard isContinuousRecognition, state == .listening else { return }
        accumulatedContinuousTime = continuousElapsedTime
        continuousStartedAt = nil
        stopRecognitionTask(cancel: false)
        state = .paused
        continuousRecognitionContinuation?.yield(.paused)
    }

    /// Resumes microphone capture in a paused continuous recognition session.
    public func resumeRecognition() throws {
        guard isContinuousRecognition, state == .paused, let recognizer = activeRecognizer else { return }
        continuousStartedAt = Date()
        state = .listening
        do {
            try startRecognitionTask(using: recognizer)
            continuousRecognitionContinuation?.yield(.resumed)
        } catch {
            continuousRecognitionContinuation?.finish(throwing: error)
            tearDownRecognition(cancelTask: true)
            throw error
        }
    }

    /// Explicitly completes a continuous recognition session.
    public func finishRecognition() {
        guard isContinuousRecognition, state == .listening || state == .paused else { return }
        continuousRecognitionContinuation?.yield(.completed)
        continuousRecognitionContinuation?.finish()
        tearDownRecognition(cancelTask: false)
    }

    private func startRecognition(using recognizer: SFSpeechRecognizer, continuous: Bool) throws {
        try configureAudioSession(category: .playAndRecord)
        activeRecognizer = recognizer
        isContinuousRecognition = continuous
        accumulatedContinuousTime = 0
        continuousStartedAt = continuous ? Date() : nil
        sessionID = UUID()
        state = .listening
        try startRecognitionTask(using: recognizer)
    }

    private func startRecognitionTask(using recognizer: SFSpeechRecognizer) throws {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = recognitionTaskHint
        if usesOnDeviceRecognition {
            guard recognizer.supportsOnDeviceRecognition else {
                throw OSSSpeechError.recognitionLocaleUnsupported(recognizer.locale.identifier)
            }
            request.requiresOnDeviceRecognition = true
        }

        let id = UUID()
        recognitionTaskID = id
        recognitionTaskOffset = continuousElapsedTime
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        guard format.channelCount > 0 else {
            tearDownRecognition(cancelTask: true)
            throw OSSSpeechError.audioEngineFailure(underlying: nil)
        }
        if tapInstalled {
            inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak request] buffer, _ in
            guard buffer.frameLength > 0 else { return }
            request?.append(buffer)
        }
        tapInstalled = true

        recognizer.defaultTaskHint = recognitionTaskHint
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self, self.recognitionTaskID == id else { return }
                if let result {
                    let text = result.bestTranscription.formattedString
                    if self.isContinuousRecognition {
                        let transcript = self.makeTranscript(from: result)
                        self.continuousRecognitionContinuation?.yield(.transcript(transcript))
                        if result.isFinal, self.state == .listening,
                           let recognizer = self.activeRecognizer {
                            self.stopRecognitionTask(cancel: false)
                            do {
                                try self.startRecognitionTask(using: recognizer)
                            } catch {
                                self.continuousRecognitionContinuation?.finish(throwing: error)
                                self.tearDownRecognition(cancelTask: true)
                            }
                        }
                    } else {
                        self.recognitionContinuation?.yield(result.isFinal ? .completed(text) : .partial(text))
                    }
                    if result.isFinal, !self.isContinuousRecognition {
                        self.recognitionContinuation?.finish()
                        self.tearDownRecognition(cancelTask: false)
                    }
                } else if let error {
                    self.recognitionContinuation?.finish(throwing: error)
                    self.tearDownRecognition(cancelTask: true)
                }
            }
        }

        audioEngine.prepare()
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                tearDownRecognition(cancelTask: true)
                throw OSSSpeechError.audioEngineFailure(underlying: error)
            }
        }
    }

    private var continuousElapsedTime: TimeInterval {
        accumulatedContinuousTime + (continuousStartedAt.map { Date().timeIntervalSince($0) } ?? 0)
    }

    private func makeTranscript(from result: SFSpeechRecognitionResult) -> OSSSpeechTranscript {
        let transcription = result.bestTranscription
        let segments = transcription.segments.map {
            OSSSpeechTranscriptSegment(
                text: $0.substring,
                timestamp: recognitionTaskOffset + $0.timestamp,
                duration: $0.duration,
                confidence: $0.confidence
            )
        }
        return OSSSpeechTranscript(
            formattedText: transcription.formattedString,
            segments: segments,
            isFinal: result.isFinal
        )
    }

    private func configureAudioSession(category: AVAudioSession.Category) throws {
        do {
            try audioSession.setCategory(category, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            throw OSSSpeechError.audioEngineFailure(underlying: error)
        }
    }

    private func tearDownRecognition(cancelTask: Bool) {
        sessionID = nil
        stopRecognitionTask(cancel: cancelTask)
        audioEngine.reset()
        recognitionContinuation = nil
        continuousRecognitionContinuation = nil
        activeRecognizer = nil
        isContinuousRecognition = false
        continuousStartedAt = nil
        accumulatedContinuousTime = 0
        recognitionTaskOffset = 0
        state = .idle
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func stopRecognitionTask(cancel: Bool) {
        recognitionTaskID = nil
        recognitionRequest?.endAudio()
        if cancel {
            recognitionTask?.cancel()
        } else {
            recognitionTask?.finish()
        }
        recognitionTask = nil
        recognitionRequest = nil
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        if tapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
    }

    private func finishSynthesis(throwing error: Error? = nil) {
        state = .idle
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        let continuation = synthesisContinuation
        synthesisContinuation = nil
        if let error {
            continuation?.resume(throwing: error)
        } else {
            continuation?.resume()
        }
    }
}

extension OSSSpeechEngine: AVSpeechSynthesizerDelegate, SFSpeechRecognizerDelegate {
    /// Completes the awaiting synthesis operation when AVFoundation finishes speaking.
    nonisolated public func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in finishSynthesis() }
    }

    /// Completes the awaiting synthesis operation with cancellation when speech is cancelled.
    nonisolated public func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in finishSynthesis(throwing: CancellationError()) }
    }

    /// Emits recognizer availability changes to the active recognition stream.
    nonisolated public func speechRecognizer(
        _ speechRecognizer: SFSpeechRecognizer,
        availabilityDidChange available: Bool
    ) {
        Task { @MainActor in
            recognitionContinuation?.yield(.availabilityChanged(available))
            continuousRecognitionContinuation?.yield(.availabilityChanged(available))
            if !available, state == .listening {
                recognitionContinuation?.finish(throwing: OSSSpeechError.recognizerUnavailable)
                continuousRecognitionContinuation?.finish(throwing: OSSSpeechError.recognizerUnavailable)
                tearDownRecognition(cancelTask: true)
            }
        }
    }
}
