# OSSSpeechKit

[![CI Status](https://img.shields.io/travis/appdevguy/OSSSpeechKit.svg?style=flat)](https://travis-ci.org/appdevguy/OSSSpeechKit)
[![Version](https://img.shields.io/cocoapods/v/OSSSpeechKit.svg?style=flat)](https://cocoapods.org/pods/OSSSpeechKit)
[![License](https://img.shields.io/cocoapods/l/OSSSpeechKit.svg?style=flat)](https://cocoapods.org/pods/OSSSpeechKit)
[![Platform](https://img.shields.io/cocoapods/p/OSSSpeechKit.svg?style=flat)](https://cocoapods.org/pods/OSSSpeechKit)
[![codecov](https://codecov.io/gh/AppDevGuy/OSSSpeechKit/branch/master/graph/badge.svg)](https://codecov.io/gh/AppDevGuy/OSSSpeechKit)
[![Inline docs](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRw%0D%0AOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB3aWR0aD0iMTM2IiBoZWlnaHQ9IjIwIj4KICA8bGlu%0D%0AZWFyR3JhZGllbnQgaWQ9ImIiIHgyPSIwIiB5Mj0iMTAwJSI+CiAgICA8c3RvcCBvZmZzZXQ9IjAi%0D%0AIHN0b3AtY29sb3I9IiNiYmIiIHN0b3Atb3BhY2l0eT0iLjEiLz4KICAgIDxzdG9wIG9mZnNldD0i%0D%0AMSIgc3RvcC1vcGFjaXR5PSIuMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPGNsaXBQYXRoIGlk%0D%0APSJhIj4KICAgIDxyZWN0IHdpZHRoPSIxMzYiIGhlaWdodD0iMjAiIHJ4PSIzIiBmaWxsPSIjZmZm%0D%0AIi8+CiAgPC9jbGlwUGF0aD4KICA8ZyBjbGlwLXBhdGg9InVybCgjYSkiPgogICAgPHBhdGggZmls%0D%0AbD0iIzU1NSIgZD0iTTAgMGg5M3YyMEgweiIvPgogICAgPHBhdGggZmlsbD0iIzRjMSIgZD0iTTkz%0D%0AIDBoNDN2MjBIOTN6Ii8+CiAgICA8cGF0aCBmaWxsPSJ1cmwoI2IpIiBkPSJNMCAwaDEzNnYyMEgw%0D%0AeiIvPgogIDwvZz4KICA8ZyBmaWxsPSIjZmZmIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LWZh%0D%0AbWlseT0iRGVqYVZ1IFNhbnMsVmVyZGFuYSxHZW5ldmEsc2Fucy1zZXJpZiIgZm9udC1zaXplPSIx%0D%0AMTAiPgogICAgPHRleHQgeD0iNDc1IiB5PSIxNTAiIGZpbGw9IiMwMTAxMDEiIGZpbGwtb3BhY2l0%0D%0AeT0iLjMiIHRyYW5zZm9ybT0ic2NhbGUoLjEpIiB0ZXh0TGVuZ3RoPSI4MzAiPgogICAgICBkb2N1%0D%0AbWVudGF0aW9uCiAgICA8L3RleHQ+CiAgICA8dGV4dCB4PSI0NzUiIHk9IjE0MCIgdHJhbnNmb3Jt%0D%0APSJzY2FsZSguMSkiIHRleHRMZW5ndGg9IjgzMCI+CiAgICAgIGRvY3VtZW50YXRpb24KICAgIDwv%0D%0AdGV4dD4KICAgIDx0ZXh0IHg9IjExMzUiIHk9IjE1MCIgZmlsbD0iIzAxMDEwMSIgZmlsbC1vcGFj%0D%0AaXR5PSIuMyIgdHJhbnNmb3JtPSJzY2FsZSguMSkiIHRleHRMZW5ndGg9IjMzMCI+CiAgICAgIDEw%0D%0AMCUKICAgIDwvdGV4dD4KICAgIDx0ZXh0IHg9IjExMzUiIHk9IjE0MCIgdHJhbnNmb3JtPSJzY2Fs%0D%0AZSguMSkiIHRleHRMZW5ndGg9IjMzMCI+CiAgICAgIDEwMCUKICAgIDwvdGV4dD4KICA8L2c+Cjwv%0D%0Ac3ZnPgo=)](https://appdevguy.github.io/OSSSpeechKit/)

OSSSpeechKit was developed to provide easier accesibility options to apps. 

Apple does not make it easy to get the right voice, nor do they provide a simple way of selecting a language. OSSSpeechKit makes the hassle of trying to find the right language go away. 

## Installation

OSSSpeechKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'OSSSpeechKit'
```

## How to use (TL;DR)

```swift
import OSSSpeechKit

.....

// Declare an instance of OSSSpeechKit
let speechKit = OSSSpeech.shared
// Set the voice you wish to use - currently upper case for formality or language and country name
speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
// Set the text in the language you have set
speechKit.speakText(text: "Hello, my name is OSSSpeechKit.")
```

That's it. You are all set. 

### Other features

#### List all available voices:

```swift
let allLanguages = OSSVoiceEnum.allCases
```

#### Get specific voice information:

```swift
let allVoices = OSSVoiceEnum.allCases
let languageInformation = allVoices[0].getDetails()
```

The `getDetails()` method will returns a struct containing:

```swift
OSSVoiceInfo {
    /// The name of the voice; All AVSpeechSynthesisVoice instances have a persons name.
    var name: String?
    /// The name of the language being used.
    var language: String?
    /// The language code is what is internationally used in Locale settings.
    var languageCode: String?
    /// Identifier is a unique bundle url provided by Apple for each AVSpeechSynthesisVoice.
    var identifier: Any?
}
```

#### Other Info

The `OSSVoiceEnum` contains other methods, such as a hello message, title variable and subtitle variable so you can use it in a list. 

You can also set the speech:

- volume
- pitchMultiplier
- rate

As well as using an `NSAttributedString`.

There are plans to implement flags for each country as well as some more features, such as being able to play the voice if the device is on silent. 

If the language or voice you require is not available, this is either due to:

- Apple have not made it avaiable through their AVFoundation; 
- or the SDK has not been updated to include the newly added voice.

## Important Information

Apple do not make the voice of Siri available for use. 

This kit provides Apple's AVFoundation voices available and easy to use, so you do not need to know all the voice codes, among many other things.

To say things correctly in each language, you need to set the voice to the correct langauge and supply that languages text; this SDK is not a translator. 

### Example:

You wish for you app to use a Chinese voice, you will need to ensure the text being passed in is German. 

_Disclaimer: I do not know how to speak Chinese, I have used Google translate for the chinese characters._

#### Correct:
```swift
speechKit.voice = OSSVoice(quality: .enhanced, language: .Chinese)
speechKit.speakText(text: "你好我的名字是 ...")
```

#### Incorrect:
```swift
speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
speechKit.speakText(text: "你好我的名字是 ...")
```

OR

```swift
speechKit.voice = OSSVoice(quality: .enhanced, language: .Chinese)
speechKit.speakText(text: "Hello, my name is ...")
```

This same principle applies to all other languages such as Chinese, Saudi Arabian, French, etc. Failing to set the language for the text you wish to be spoken will not sound correct. 

If you have a question, please create a ticket or email me directly. 

If you wish to contribute, please create a pull request. 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

OSSSpeechKit is written in Swift 5.0. You will need to be using iOS 12 and up to use this. 

There are no plans to make it accesible to earlier iOS versions. 

## Author

App Dev Guy, seaniosdeveloper@gmail.com

## License

OSSSpeechKit is available under the MIT license. See the LICENSE file for more info.
