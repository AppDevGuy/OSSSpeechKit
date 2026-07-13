import Foundation
import OSSSpeechKit
import XCTest

@MainActor
final class RecordingSessionModelTests: XCTestCase {
    func testSessionStartsAndRetainsRowsAcrossVerbalAndTechnicalPauses() async {
        let engine = RecognitionSessionProviderMock()
        var currentDate = Date(timeIntervalSinceReferenceDate: 1_000)
        let model = RecordingSessionModel(
            language: OSSLanguage.catalog[0],
            engine: engine,
            now: { currentDate }
        )

        model.start()
        await allowTasksToRun()
        XCTAssertEqual(model.status, .recording)
        XCTAssertEqual(engine.startCount, 1)

        engine.send(.transcript(makeTranscript("First sentence", timestamp: 0, isFinal: true)))
        await allowTasksToRun()
        XCTAssertEqual(model.rows, [.init(timestamp: 0, text: "First sentence")])

        currentDate.addTimeInterval(4)
        engine.send(.transcript(makeTranscript("Second thought", timestamp: 3, isFinal: false)))
        await allowTasksToRun()
        model.pause()

        XCTAssertEqual(model.status, .paused)
        XCTAssertEqual(model.rows.map(\.text), ["First sentence", "Second thought"])
        XCTAssertEqual(model.elapsedTime, 4, accuracy: 0.001)
        XCTAssertEqual(engine.pauseCount, 1)

        currentDate.addTimeInterval(20)
        model.resume()
        XCTAssertEqual(model.status, .recording)
        XCTAssertEqual(model.rows.map(\.text), ["First sentence", "Second thought"])
        XCTAssertEqual(engine.resumeCount, 1)

        currentDate.addTimeInterval(2)
        XCTAssertEqual(model.elapsedTime, 6, accuracy: 0.001)
    }

    func testStopFinalizesLiveTextAndCompletesOnlyOnce() async {
        let engine = RecognitionSessionProviderMock()
        let model = RecordingSessionModel(
            language: OSSLanguage.catalog[0],
            engine: engine
        )
        var stopCount = 0
        model.onStop = { stopCount += 1 }

        model.start()
        await allowTasksToRun()
        let liveTextReceived = expectation(description: "Live transcript received")
        model.onChange = {
            if model.liveText == "Unfinished phrase" {
                model.onChange = nil
                liveTextReceived.fulfill()
            }
        }
        engine.send(.transcript(makeTranscript("Unfinished phrase", timestamp: 1, isFinal: false)))
        await fulfillment(of: [liveTextReceived], timeout: 1)

        model.stop()
        model.stop()

        XCTAssertEqual(model.status, .stopped)
        XCTAssertEqual(model.rows.map(\.text), ["Unfinished phrase"])
        XCTAssertEqual(engine.finishCount, 1)
        XCTAssertEqual(stopCount, 1)
    }

    func testLongWordGapCreatesANewTranscriptRow() async {
        let engine = RecognitionSessionProviderMock()
        let model = RecordingSessionModel(
            language: OSSLanguage.catalog[0],
            engine: engine
        )
        model.start()
        await allowTasksToRun()

        engine.send(.transcript(.init(
            formattedText: "Hello there This",
            segments: [
                .init(text: "Hello", timestamp: 0, duration: 0.2, confidence: 0.9),
                .init(text: "there", timestamp: 0.35, duration: 0.2, confidence: 0.9),
                .init(text: "This", timestamp: 1.4, duration: 0.2, confidence: 0.9)
            ],
            isFinal: false
        )))
        await allowTasksToRun()

        XCTAssertEqual(model.rows, [.init(timestamp: 0, text: "Hello there")])
        XCTAssertEqual(model.liveText, "This")

        engine.send(.transcript(.init(
            formattedText: "Hello there This is.",
            segments: [
                .init(text: "Hello", timestamp: 0, duration: 0.2, confidence: 0.9),
                .init(text: "there", timestamp: 0.35, duration: 0.2, confidence: 0.9),
                .init(text: "This", timestamp: 1.4, duration: 0.2, confidence: 0.9),
                .init(text: "is", timestamp: 1.7, duration: 0.2, confidence: 0.9),
                .init(text: ".", timestamp: 2, duration: 0.1, confidence: 0.9)
            ],
            isFinal: true
        )))
        await allowTasksToRun()

        XCTAssertEqual(model.rows.map(\.text), ["Hello there", "This is."])
        XCTAssertTrue(model.liveText.isEmpty)
    }

    func testTranscriptInactivityCreatesRowWhenAppleSegmentIncludesSilence() async {
        let engine = RecognitionSessionProviderMock()
        var currentDate = Date(timeIntervalSinceReferenceDate: 1_000)
        let model = RecordingSessionModel(
            language: OSSLanguage.catalog[0],
            engine: engine,
            now: { currentDate }
        )
        model.start()
        await allowTasksToRun()

        let firstRowCreated = expectation(description: "Silence finalizes the first row")
        model.onChange = {
            if model.rows.map(\.text) == ["Before pause"] {
                model.onChange = nil
                firstRowCreated.fulfill()
            }
        }
        engine.send(.transcript(.init(
            formattedText: "Before pause",
            segments: [
                .init(text: "Before pause", timestamp: 0, duration: 2, confidence: 0.9)
            ],
            isFinal: false
        )))
        await fulfillment(of: [firstRowCreated], timeout: 2)

        currentDate.addTimeInterval(3)
        let secondPhraseReceived = expectation(description: "New words use a new live row")
        model.onChange = {
            if model.liveText == "After pause" {
                model.onChange = nil
                secondPhraseReceived.fulfill()
            }
        }
        engine.send(.transcript(.init(
            formattedText: "Before pause After pause",
            segments: [
                .init(text: "Before pause", timestamp: 0, duration: 2, confidence: 0.9),
                .init(text: "After pause", timestamp: 1.2, duration: 0.3, confidence: 0.9)
            ],
            isFinal: false
        )))
        await fulfillment(of: [secondPhraseReceived], timeout: 1)

        XCTAssertEqual(model.rows, [.init(timestamp: 0, text: "Before pause")])
        XCTAssertEqual(model.liveTimestamp, 3)
    }

    func testTimestampFormattingUsesRecordingStyleClock() {
        let model = RecordingSessionModel(language: OSSLanguage.catalog[0])
        XCTAssertEqual(model.formattedTimestamp(0), "00:00")
        XCTAssertEqual(model.formattedTimestamp(65), "01:05")
        XCTAssertEqual(model.formattedTimestamp(3_661), "1:01:01")
    }

    private func makeTranscript(
        _ text: String,
        timestamp: TimeInterval,
        isFinal: Bool
    ) -> OSSSpeechTranscript {
        OSSSpeechTranscript(
            formattedText: text,
            segments: [
                .init(text: text, timestamp: timestamp, duration: 1, confidence: 0.9)
            ],
            isFinal: isFinal
        )
    }

    private func allowTasksToRun() async {
        await Task.yield()
        await Task.yield()
    }
}

@MainActor
private final class RecognitionSessionProviderMock: SpeechRecognitionSessionProviding {
    private var continuation:
        AsyncThrowingStream<OSSSpeechContinuousRecognitionEvent, Error>.Continuation?

    private(set) var startCount = 0
    private(set) var pauseCount = 0
    private(set) var resumeCount = 0
    private(set) var finishCount = 0
    private(set) var cancelCount = 0

    func continuousRecognitionEvents(
        locale: Locale,
        requestAuthorization: Bool
    ) async throws -> AsyncThrowingStream<OSSSpeechContinuousRecognitionEvent, Error> {
        startCount += 1
        return AsyncThrowingStream { continuation in
            self.continuation = continuation
        }
    }

    func pauseRecognition() {
        pauseCount += 1
    }

    func resumeRecognition() throws {
        resumeCount += 1
    }

    func finishRecognition() {
        finishCount += 1
        continuation?.yield(.completed)
        continuation?.finish()
    }

    func cancelRecognition() {
        cancelCount += 1
        continuation?.yield(.cancelled)
        continuation?.finish()
    }

    func send(_ event: OSSSpeechContinuousRecognitionEvent) {
        continuation?.yield(event)
    }
}
