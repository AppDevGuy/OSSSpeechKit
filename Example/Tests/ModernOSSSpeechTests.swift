import AVFoundation
import Speech
import XCTest
@testable import OSSSpeechKit

final class ModernOSSSpeechTests: XCTestCase {
    func testLanguageCatalogHasUniqueStableIdentifiers() {
        let identifiers = OSSLanguage.catalog.map(\.id)
        XCTAssertEqual(Set(identifiers).count, identifiers.count)
        XCTAssertTrue(OSSLanguage.catalog.allSatisfy { !$0.localeIdentifier.isEmpty })
    }

    func testCatalogIncludesModernAppleLanguageCandidates() {
        let expected = [
            "basque", "bengali", "bhojpuri", "english-scotland", "farsi",
            "french-belgium", "galician", "kannada", "kazakh", "lithuanian",
            "marathi", "slovenian", "spanish-argentina", "spanish-chile",
            "spanish-colombia", "tamil", "telugu", "valencian"
        ]
        XCTAssertTrue(expected.allSatisfy { id in
            OSSLanguage.catalog.contains(where: { $0.id == id })
        })
    }

    func testEveryLanguageHasAnEmojiAndRenderableImage() {
        for language in OSSLanguage.catalog {
            XCTAssertFalse(language.flagEmoji.isEmpty, language.id)
            let image = language.renderedFlagImage(pointSize: 24, scale: 2)
            XCTAssertGreaterThan(image.size.width, 0, language.id)
            XCTAssertGreaterThan(image.size.height, 0, language.id)
        }
    }

    func testFlagRendererCachesEquivalentRequests() {
        let language = OSSLanguage.catalog[0]
        let first = language.renderedFlagImage(pointSize: 24, scale: 2)
        let second = language.renderedFlagImage(pointSize: 24, scale: 2)
        XCTAssertTrue(first === second)
    }

    @available(*, deprecated, message: "Legacy compatibility coverage")
    func testLegacyLocaleMigrationsDoNotCrossRegions() {
        XCTAssertEqual(OSSVoiceEnum.Chinese.canonicalLocaleIdentifier, "zh-CN")
        XCTAssertEqual(OSSVoiceEnum.ChineseHongKong.canonicalLocaleIdentifier, "yue-HK")
        XCTAssertEqual(OSSVoiceEnum.Norwegian.canonicalLocaleIdentifier, "nb-NO")
        XCTAssertEqual(OSSVoiceEnum.ArabicWorld.flagEmoji, "🌐")
    }

    func testRecognitionMatchingRequiresSameLanguageAndRegion() throws {
        let supported = SFSpeechRecognizer.supportedLocales()
        guard let sample = supported.first(where: { $0.language.region != nil }) else {
            throw XCTSkip("No regional recognition locales are exposed on this host.")
        }
        XCTAssertEqual(
            OSSLanguage.supportedRecognitionLocale(equivalentTo: sample)?.identifier,
            sample.identifier
        )
    }

    @MainActor
    func testModernEngineStartsIdle() {
        let engine = OSSSpeechEngine()
        engine.stopSpeaking()
        engine.cancelRecognition()
        XCTAssertEqual(engine.state, .idle)
    }

    func testTypedErrorsProvideActionableDescriptions() {
        XCTAssertNotNil(OSSSpeechError.emptyText.errorDescription)
        XCTAssertNotNil(OSSSpeechError.recognizerUnavailable.errorDescription)
        XCTAssertNotNil(
            OSSSpeechError.recognitionLocaleUnsupported("xx-YY").errorDescription
        )
    }

    func testTranscriptValuesRetainTimingAndFinalState() {
        let segment = OSSSpeechTranscriptSegment(
            text: "Hello",
            timestamp: 1.25,
            duration: 0.4,
            confidence: 0.95
        )
        let transcript = OSSSpeechTranscript(
            formattedText: "Hello",
            segments: [segment],
            isFinal: true
        )

        XCTAssertEqual(transcript.formattedText, "Hello")
        XCTAssertEqual(transcript.segments, [segment])
        XCTAssertTrue(transcript.isFinal)
    }
}
