# Changelog

All notable changes to OSSSpeechKit are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and releases use [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-07-13

### Added

- `OSSSpeechEngine`, an instance-based async API for synthesis and recognition.
- `OSSLanguage` runtime-aware language metadata and catalog.
- `OSSVoiceConfiguration` and `OSSUtteranceConfiguration` value types.
- Unicode `flagEmoji` and on-demand UIKit flag rendering.
- Swift Package Manager support for every source under `OSSSpeechKit/Classes`.
- A privacy manifest for the SDK's data practices.

### Changed

- Raised the minimum deployment target to iOS 17.
- Made Swift Package Manager the sole supported installation path.
- Modernized continuous integration for package and example tests.
- Limited published package products and platform frameworks to the supported iOS library.

### Deprecated

- `OSSSpeech` and its shared singleton in favor of `OSSSpeechEngine`.
- `OSSVoice` in favor of `OSSVoiceConfiguration`.
- `OSSUtterance` in favor of `OSSUtteranceConfiguration`.
- Legacy `OSSVoiceEnum` catalog and image flag access in favor of `OSSLanguage`.

### Removed

- CocoaPods distribution and contributor tooling. The historical `0.3.3` pod remains resolvable but is unsupported; version 1.0 and later are available only through Swift Package Manager.

[1.0.0]: https://github.com/AppDevGuy/OSSSpeechKit/releases/tag/1.0.0
