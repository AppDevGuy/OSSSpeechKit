import AVFoundation
import Foundation

/// Selects an actual voice exposed by AVFoundation.
public struct OSSVoiceConfiguration {
    /// Language or regional variant used to search installed voices.
    public var language: OSSLanguage

    /// Specific AVFoundation voice identifier to prefer when available.
    public var preferredIdentifier: String?

    /// Preferred voice quality to use when multiple voices match the language.
    public var preferredQuality: AVSpeechSynthesisVoiceQuality?

    /// Creates a voice selection request.
    ///
    /// - Parameters:
    ///   - language: Language metadata used to find matching voices.
    ///   - preferredIdentifier: Optional exact AVFoundation voice identifier.
    ///   - preferredQuality: Optional quality preference for matched voices.
    public init(
        language: OSSLanguage,
        preferredIdentifier: String? = nil,
        preferredQuality: AVSpeechSynthesisVoiceQuality? = nil
    ) {
        self.language = language
        self.preferredIdentifier = preferredIdentifier
        self.preferredQuality = preferredQuality
    }

    /// Resolves the best currently available system voice without relying on
    /// AVFoundation's silent cross-region fallback.
    public func resolve() -> AVSpeechSynthesisVoice? {
        if let preferredIdentifier,
           let voice = AVSpeechSynthesisVoice(identifier: preferredIdentifier) {
            return voice
        }

        if let directMatch = AVSpeechSynthesisVoice(language: language.localeIdentifier) {
            if preferredQuality == nil || directMatch.quality == preferredQuality {
                return directMatch
            }
        }

        let voices = language.availableSynthesisVoices
        if let preferredQuality,
           let qualityMatch = voices.first(where: { $0.quality == preferredQuality }) {
            return qualityMatch
        }
        return voices.first
    }
}

/// Value-style speech parameters used to construct a fresh AVFoundation
/// utterance for every synthesis request.
public struct OSSUtteranceConfiguration {
    /// Speech rate to apply to the utterance.
    public var rate: Float

    /// Pitch multiplier to apply to the utterance.
    public var pitchMultiplier: Float

    /// Playback volume to apply to the utterance.
    public var volume: Float

    /// Delay before the utterance begins speaking.
    public var preUtteranceDelay: TimeInterval

    /// Delay after the utterance finishes speaking.
    public var postUtteranceDelay: TimeInterval

    /// Creates speech synthesis parameters for an utterance.
    ///
    /// - Parameters:
    ///   - rate: Speech rate to apply.
    ///   - pitchMultiplier: Pitch multiplier to apply.
    ///   - volume: Playback volume to apply.
    ///   - preUtteranceDelay: Delay before speaking begins.
    ///   - postUtteranceDelay: Delay after speaking finishes.
    public init(
        rate: Float = AVSpeechUtteranceDefaultSpeechRate,
        pitchMultiplier: Float = 1,
        volume: Float = 1,
        preUtteranceDelay: TimeInterval = 0,
        postUtteranceDelay: TimeInterval = 0
    ) {
        self.rate = rate
        self.pitchMultiplier = pitchMultiplier
        self.volume = volume
        self.preUtteranceDelay = preUtteranceDelay
        self.postUtteranceDelay = postUtteranceDelay
    }

    func apply(to utterance: AVSpeechUtterance) {
        utterance.rate = rate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.volume = volume
        utterance.preUtteranceDelay = preUtteranceDelay
        utterance.postUtteranceDelay = postUtteranceDelay
    }
}

@available(*, deprecated, message: "Use OSSUtteranceConfiguration and pass text directly to OSSSpeech.")
extension OSSUtterance {
    var configuration: OSSUtteranceConfiguration {
        OSSUtteranceConfiguration(
            rate: rate,
            pitchMultiplier: pitchMultiplier,
            volume: volume,
            preUtteranceDelay: preUtteranceDelay,
            postUtteranceDelay: postUtteranceDelay
        )
    }
}

@available(*, deprecated, message: "Use OSSVoiceConfiguration.")
extension OSSVoice {
    var configuration: OSSVoiceConfiguration {
        OSSVoiceConfiguration(
            language: voiceType.languageMetadata,
            preferredQuality: quality
        )
    }
}
