import AVFoundation
import Foundation
import Speech

/// Display metadata for a language or regional voice supported by Apple platforms.
///
/// The catalog is intentionally separate from runtime capabilities. Use
/// ``availableSynthesisVoices`` and ``supportsRecognition`` before presenting an
/// operation as available on the current device.
public struct OSSLanguage: Hashable, Identifiable, Sendable {
    /// Stable identifier used by OSSSpeechKit to refer to this catalog entry.
    public let id: String

    /// Human-readable language or regional variant name for display.
    public let name: String

    /// Foundation locale that describes the language and region.
    public let locale: Locale

    /// Region override used when the locale alone cannot distinguish a variant.
    public let regionCode: String?

    /// Voice identifiers that should be preferred when matching installed voices.
    public let preferredVoiceIdentifiers: [String]

    /// Creates language metadata for the OSSSpeechKit catalog.
    ///
    /// - Parameters:
    ///   - id: Stable catalog identifier.
    ///   - name: Human-readable display name.
    ///   - localeIdentifier: BCP 47 identifier for the language and region.
    ///   - regionCode: Optional region override for variants that share a locale.
    ///   - preferredVoiceIdentifiers: Preferred AVFoundation voice identifiers.
    public init(
        id: String,
        name: String,
        localeIdentifier: String,
        regionCode: String? = nil,
        preferredVoiceIdentifiers: [String] = []
    ) {
        self.id = id
        self.name = name
        locale = Locale(identifier: localeIdentifier)
        self.regionCode = regionCode
        self.preferredVoiceIdentifiers = preferredVoiceIdentifiers
    }

    /// The canonicalized BCP 47 identifier used for runtime capability checks.
    public var localeIdentifier: String {
        locale.identifier
    }

    /// Voices currently installed or exposed by the operating system.
    public var availableSynthesisVoices: [AVSpeechSynthesisVoice] {
        let requested = Locale(identifier: localeIdentifier)
        guard let requestedLanguageCode = requested.language.languageCode else {
            return []
        }
        return AVSpeechSynthesisVoice.speechVoices().filter {
            let candidate = Locale(identifier: $0.language)
            return candidate.identifier == requested.identifier ||
                (candidate.language.languageCode == requestedLanguageCode &&
                 candidate.language.region == requested.language.region)
        }
    }

    /// Whether the legacy Speech recognizer reports this locale as supported.
    ///
    /// Support does not imply that Apple's service is currently available.
    public var supportsRecognition: Bool {
        Self.supportedRecognitionLocale(equivalentTo: locale) != nil
    }

    /// Returns the exact supported recognition locale, or a same-language,
    /// same-region canonical equivalent. It never silently changes regions.
    public static func supportedRecognitionLocale(equivalentTo locale: Locale) -> Locale? {
        let requested = Locale(identifier: locale.identifier)
        guard let requestedLanguageCode = requested.language.languageCode else {
            return nil
        }
        return SFSpeechRecognizer.supportedLocales().first { candidate in
            candidate.identifier == requested.identifier ||
                (candidate.language.languageCode == requestedLanguageCode &&
                 candidate.language.region == requested.language.region)
        }
    }
}

public extension OSSLanguage {
    /// Curated languages and regional variants described by Apple's current
    /// VoiceOver and Dictation availability documentation.
    ///
    /// Availability still varies by OS release, device, installed assets, and
    /// network access. Filter this catalog using the runtime capability APIs.
    static let catalog: [OSSLanguage] = [
        .init(id: "arabic-world", name: "Arabic (World)", localeIdentifier: "ar-001"),
        .init(id: "arabic-saudi-arabia", name: "Arabic (Saudi Arabia)", localeIdentifier: "ar-SA"),
        .init(id: "basque", name: "Basque", localeIdentifier: "eu-ES"),
        .init(id: "bengali", name: "Bengali", localeIdentifier: "bn-IN"),
        .init(id: "bhojpuri", name: "Bhojpuri", localeIdentifier: "bho-IN"),
        .init(id: "bulgarian", name: "Bulgarian", localeIdentifier: "bg-BG"),
        .init(id: "catalan", name: "Catalan", localeIdentifier: "ca-ES"),
        .init(id: "chinese-cantonese-hong-kong", name: "Chinese, Cantonese (Hong Kong)", localeIdentifier: "yue-HK"),
        .init(id: "chinese-mandarin-china", name: "Chinese, Mandarin (China mainland)", localeIdentifier: "zh-CN"),
        .init(id: "chinese-mandarin-taiwan", name: "Chinese, Mandarin (Taiwan)", localeIdentifier: "zh-TW"),
        .init(id: "croatian", name: "Croatian", localeIdentifier: "hr-HR"),
        .init(id: "czech", name: "Czech", localeIdentifier: "cs-CZ"),
        .init(id: "danish", name: "Danish", localeIdentifier: "da-DK"),
        .init(id: "dutch-belgium", name: "Dutch (Belgium)", localeIdentifier: "nl-BE"),
        .init(id: "dutch-netherlands", name: "Dutch (Netherlands)", localeIdentifier: "nl-NL"),
        .init(id: "english-australia", name: "English (Australia)", localeIdentifier: "en-AU"),
        .init(id: "english-india", name: "English (India)", localeIdentifier: "en-IN"),
        .init(id: "english-ireland", name: "English (Ireland)", localeIdentifier: "en-IE"),
        .init(id: "english-scotland", name: "English (Scotland)", localeIdentifier: "en-GB", regionCode: "GB"),
        .init(id: "english-south-africa", name: "English (South Africa)", localeIdentifier: "en-ZA"),
        .init(id: "english-uk", name: "English (United Kingdom)", localeIdentifier: "en-GB"),
        .init(id: "english-us", name: "English (United States)", localeIdentifier: "en-US"),
        .init(id: "farsi", name: "Farsi", localeIdentifier: "fa-IR"),
        .init(id: "finnish", name: "Finnish", localeIdentifier: "fi-FI"),
        .init(id: "french-belgium", name: "French (Belgium)", localeIdentifier: "fr-BE"),
        .init(id: "french-canada", name: "French (Canada)", localeIdentifier: "fr-CA"),
        .init(id: "french-france", name: "French (France)", localeIdentifier: "fr-FR"),
        .init(id: "galician", name: "Galician", localeIdentifier: "gl-ES"),
        .init(id: "german", name: "German", localeIdentifier: "de-DE"),
        .init(id: "greek", name: "Greek", localeIdentifier: "el-GR"),
        .init(id: "hebrew", name: "Hebrew", localeIdentifier: "he-IL"),
        .init(id: "hindi", name: "Hindi", localeIdentifier: "hi-IN"),
        .init(id: "hungarian", name: "Hungarian", localeIdentifier: "hu-HU"),
        .init(id: "indonesian", name: "Indonesian", localeIdentifier: "id-ID"),
        .init(id: "italian", name: "Italian", localeIdentifier: "it-IT"),
        .init(id: "japanese", name: "Japanese", localeIdentifier: "ja-JP"),
        .init(id: "kannada", name: "Kannada", localeIdentifier: "kn-IN"),
        .init(id: "kazakh", name: "Kazakh", localeIdentifier: "kk-KZ"),
        .init(id: "korean", name: "Korean", localeIdentifier: "ko-KR"),
        .init(id: "lithuanian", name: "Lithuanian", localeIdentifier: "lt-LT"),
        .init(id: "malay", name: "Malay", localeIdentifier: "ms-MY"),
        .init(id: "marathi", name: "Marathi", localeIdentifier: "mr-IN"),
        .init(id: "norwegian-bokmal", name: "Norwegian Bokmål", localeIdentifier: "nb-NO"),
        .init(id: "polish", name: "Polish", localeIdentifier: "pl-PL"),
        .init(id: "portuguese-brazil", name: "Portuguese (Brazil)", localeIdentifier: "pt-BR"),
        .init(id: "portuguese-portugal", name: "Portuguese (Portugal)", localeIdentifier: "pt-PT"),
        .init(id: "romanian", name: "Romanian", localeIdentifier: "ro-RO"),
        .init(id: "russian", name: "Russian", localeIdentifier: "ru-RU"),
        .init(id: "slovak", name: "Slovak", localeIdentifier: "sk-SK"),
        .init(id: "slovenian", name: "Slovenian", localeIdentifier: "sl-SI"),
        .init(id: "spanish-argentina", name: "Spanish (Argentina)", localeIdentifier: "es-AR"),
        .init(id: "spanish-chile", name: "Spanish (Chile)", localeIdentifier: "es-CL"),
        .init(id: "spanish-colombia", name: "Spanish (Colombia)", localeIdentifier: "es-CO"),
        .init(id: "spanish-mexico", name: "Spanish (Mexico)", localeIdentifier: "es-MX"),
        .init(id: "spanish-spain", name: "Spanish (Spain)", localeIdentifier: "es-ES"),
        .init(id: "swedish", name: "Swedish", localeIdentifier: "sv-SE"),
        .init(id: "tamil", name: "Tamil", localeIdentifier: "ta-IN"),
        .init(id: "telugu", name: "Telugu", localeIdentifier: "te-IN"),
        .init(id: "thai", name: "Thai", localeIdentifier: "th-TH"),
        .init(id: "turkish", name: "Turkish", localeIdentifier: "tr-TR"),
        .init(id: "ukrainian", name: "Ukrainian", localeIdentifier: "uk-UA"),
        .init(id: "valencian", name: "Valencian", localeIdentifier: "ca-ES", regionCode: "ES"),
        .init(id: "vietnamese", name: "Vietnamese", localeIdentifier: "vi-VN")
    ]
}
