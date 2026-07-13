# Migrating to OSSSpeechKit 1.0

Version 1.0 requires iOS 17 and introduces an instance-based, async API. Legacy APIs remain deprecated so migration can be incremental.

## Installation

Remove OSSSpeechKit from your Podfile, then add the package URL in Xcode under **File > Add Package Dependencies**:

```text
https://github.com/AppDevGuy/OSSSpeechKit.git
```

Select version `1.0.0` or later. Swift Package Manager is the only supported installation method for version 1.0 and later. The historical CocoaPods release `0.3.3` remains available for existing builds but is no longer maintained.

## Replace the shared engine

Before:

```swift
let speech = OSSSpeech.shared
speech.speakText("Hello")
```

After:

```swift
let engine = OSSSpeechEngine()
let language = OSSLanguage.catalog.first {
    $0.id == "english-us"
}!

try await engine.speak(
    "Hello",
    voice: OSSVoiceConfiguration(language: language)
)
```

Keep the engine alive for the lifetime of the feature using it. `OSSSpeechEngine` is main-actor isolated, exposes its current state, and rejects overlapping speech operations.

## Replace voice and utterance subclasses

`OSSVoice` and `OSSUtterance` subclass Apple framework types and are deprecated. Use value configurations:

```swift
let voice = OSSVoiceConfiguration(
    language: language,
    preferredIdentifier: nil,
    preferredQuality: .enhanced
)

let utterance = OSSUtteranceConfiguration(
    rate: 0.5,
    pitchMultiplier: 1.1,
    volume: 0.8
)

try await engine.speak(
    "Configured speech",
    voice: voice,
    configuration: utterance
)
```

Voice selection now fails with `OSSSpeechError.voiceUnavailable` instead of silently accepting an unavailable regional voice.

## Migrate language and flag UI

Use `OSSLanguage.catalog` instead of treating `OSSVoiceEnum.allCases` as a capability list:

```swift
let visibleLanguages = OSSLanguage.catalog.filter {
    !$0.availableSynthesisVoices.isEmpty || $0.supportsRecognition
}
```

Use `language.flagEmoji` for text and SwiftUI. For UIKit image views:

```swift
imageView.image = language.renderedFlagImage(pointSize: 24)
```

The catalog describes known languages and regional variants. Installed synthesis voices and recognition support must still be checked at runtime.

## Migrate recognition

Before:

```swift
speech.delegate = self
speech.recordVoice()
// Later:
speech.endVoiceRecording()
```

After:

```swift
let events = try await engine.recognitionEvents(
    locale: Locale(identifier: "en-US")
)

for try await event in events {
    switch event {
    case .partial(let text), .completed(let text):
        updateTranscript(text)
    case .availabilityChanged(let available):
        updateAvailability(available)
    case .cancelled:
        break
    }
}
```

Call `engine.cancelRecognition()` to stop. Permission failures and unsupported locales are reported as thrown errors.

If you set `engine.usesOnDeviceRecognition = true`, verify that the selected recognizer supports it. Availability differs by device, locale, installed assets, and OS version.

## Privacy requirements

The consuming app must provide meaningful values for:

- `NSMicrophoneUsageDescription`
- `NSSpeechRecognitionUsageDescription`

The SDK privacy manifest describes OSSSpeechKit itself. It does not supply these usage descriptions or replace your app's privacy disclosures.

## Deprecated API mapping

- `OSSSpeech.shared` → retained `OSSSpeechEngine` instance
- `speakText` / `speakAttributedText` → async `speak`
- delegate recognition callbacks → `recognitionEvents(locale:)`
- `endVoiceRecording()` → `cancelRecognition()`
- `OSSVoice` → `OSSVoiceConfiguration`
- `OSSUtterance` → `OSSUtteranceConfiguration`
- `OSSVoiceEnum.allCases` → `OSSLanguage.catalog`
- `OSSVoiceEnum.flag` → `flagEmoji` or `renderedFlagImage(pointSize:scale:)`
