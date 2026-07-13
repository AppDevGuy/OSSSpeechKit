# OSSSpeechKit

OSSSpeechKit is an iOS library for speech synthesis and speech recognition built on Apple's `AVFoundation` and `Speech` frameworks.

## Requirements

- iOS 17 or later
- Swift 5 language mode or later
- Xcode with Swift 6 package support

## Installation

In Xcode, choose **File > Add Package Dependencies**, enter:

```text
https://github.com/AppDevGuy/OSSSpeechKit.git
```

Select version `1.0.0` or later and add the `OSSSpeechKit` library product to your app target.

You can also add it to `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/AppDevGuy/OSSSpeechKit.git",
        from: "1.0.0"
    )
]
```

Swift Package Manager is the only supported installation method. The historical CocoaPods release `0.3.3` remains available for existing builds but is no longer maintained; version 1.0 and later are not published to CocoaPods.

## Speech synthesis

`OSSSpeechEngine` is main-actor isolated and instance based. Select a language from the catalog, confirm that a voice exists on the current device, then speak:

```swift
import AVFoundation
import OSSSpeechKit

let engine = OSSSpeechEngine()
let language = OSSLanguage.catalog.first {
    $0.id == "english-australia"
}!

guard !language.availableSynthesisVoices.isEmpty else {
    // Ask the user to install a compatible system voice.
    return
}

try await engine.speak(
    "Hello from OSSSpeechKit.",
    voice: OSSVoiceConfiguration(
        language: language,
        preferredQuality: .enhanced
    ),
    configuration: OSSUtteranceConfiguration(
        rate: AVSpeechUtteranceDefaultSpeechRate,
        pitchMultiplier: 1,
        volume: 1
    )
)
```

Use `pauseSpeaking()`, `continueSpeaking()`, and `stopSpeaking()` to control playback.

## Speech recognition

Add both usage descriptions to the consuming app's `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Explain why your app records audio.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Explain why your app transcribes speech.</string>
```

Then consume recognition events:

```swift
let engine = OSSSpeechEngine()

do {
    let events = try await engine.recognitionEvents(
        locale: Locale(identifier: "en-AU")
    )

    for try await event in events {
        switch event {
        case .partial(let text):
            print("Partial:", text)
        case .completed(let text):
            print("Final:", text)
        case .availabilityChanged(let available):
            print("Available:", available)
        case .cancelled:
            break
        }
    }
} catch {
    print("Recognition failed:", error)
}
```

Call `cancelRecognition()` to stop an active session. Set `usesOnDeviceRecognition = true` before starting if your product requires on-device recognition; the operation fails when the selected recognizer does not support it.

For a dictation-style session that stays open across verbal pauses, consume the
continuous event stream:

```swift
let events = try await engine.continuousRecognitionEvents(
    locale: Locale(identifier: "en-AU")
)

for try await event in events {
    switch event {
    case .transcript(let transcript):
        print(transcript.formattedText)
        for segment in transcript.segments {
            print(segment.timestamp, segment.duration, segment.text)
        }
    case .paused:
        print("Capture paused")
    case .resumed:
        print("Capture resumed")
    case .completed, .cancelled:
        break
    case .availabilityChanged(let available):
        print("Available:", available)
    }
}
```

Use `pauseRecognition()` and `resumeRecognition()` to suspend and restart
microphone capture while retaining the same event stream. Call
`finishRecognition()` to end successfully, or `cancelRecognition()` to cancel.
Segment timestamps use active recording time, so time spent paused is excluded.
The API transcribes live microphone input; it does not save an audio file.

## Languages, voices, and flags

`OSSLanguage.catalog` is display metadata, not a guarantee of runtime support. Availability varies by OS release, device, installed voice assets, region, network access, and Apple's services.

The catalog was reconciled against Apple's current
[VoiceOver language support](https://support.apple.com/en-us/111748) and
[feature availability](https://www.apple.com/ios/feature-availability/) pages.
Exact synthesis voices come from
[`AVSpeechSynthesisVoice.speechVoices()`](https://developer.apple.com/documentation/avfaudio/avspeechsynthesisvoice/speechvoices())
and recognition locales come from
[`SFSpeechRecognizer.supportedLocales()`](https://developer.apple.com/documentation/speech/sfspeechrecognizer/supportedlocales());
those runtime results are authoritative.

Check capabilities when presenting an option:

```swift
for language in OSSLanguage.catalog {
    let canSpeak = !language.availableSynthesisVoices.isEmpty
    let canRecognize = language.supportsRecognition
    let flag = language.flagEmoji
    print(flag, language.name, canSpeak, canRecognize)
}
```

For UIKit code that needs an image, use:

```swift
let image = language.renderedFlagImage(pointSize: 24)
```

Speech synthesis is not translation. Supply text written for the selected language and locale.

## Privacy

OSSSpeechKit requests microphone and speech-recognition permission only when your app asks it to. Your app is responsible for clear `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` strings and for disclosing its own data practices.

Speech recognition may use Apple services unless on-device recognition is requested and supported. Review Apple's current Speech framework and App Store privacy requirements for your use case.

The included `PrivacyInfo.xcprivacy` declares that OSSSpeechKit itself does not track users, collect data, or access a required-reason API. It does not replace the consuming app's privacy manifest or App Privacy answers.

## Migrating from pre-1.0

The singleton and subclass-based APIs remain temporarily available but are deprecated:

- `OSSSpeech.shared` → create an `OSSSpeechEngine`
- `OSSVoice` → `OSSVoiceConfiguration`
- `OSSUtterance` → `OSSUtteranceConfiguration`
- `OSSVoiceEnum.flag` → `flagEmoji` or `renderedFlagImage(pointSize:scale:)`
- `OSSVoiceEnum` catalogs → `OSSLanguage.catalog`

See [MIGRATION.md](MIGRATION.md) for examples and behavior changes.

## Example and tests

Open `Example/OSSSpeechKit.xcodeproj` to run the example app and its tests. The project links the package from the repository root.

## License

OSSSpeechKit is available under the MIT license. See [LICENSE](LICENSE).
