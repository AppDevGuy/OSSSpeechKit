
# OSSSpeechKit

[![OSSSpeechKit Logo](https://appdevguy.github.io/OSSSpeechKit/OSSSpeechKit-Logo.png)](https://github.com/AppDevGuy/OSSSpeechKit)

[![CI Status](https://img.shields.io/travis/appdevguy/OSSSpeechKit.svg?style=flat)](https://travis-ci.org/appdevguy/OSSSpeechKit)
[![Version](https://img.shields.io/cocoapods/v/OSSSpeechKit.svg?style=flat)](https://cocoapods.org/pods/OSSSpeechKit)
[![License](https://img.shields.io/cocoapods/l/OSSSpeechKit.svg?style=flat)](https://cocoapods.org/pods/OSSSpeechKit)
[![Platform](https://img.shields.io/cocoapods/p/OSSSpeechKit.svg?style=flat)](https://cocoapods.org/pods/OSSSpeechKit)
[![codecov](https://codecov.io/gh/AppDevGuy/OSSSpeechKit/branch/master/graph/badge.svg)](https://codecov.io/gh/AppDevGuy/OSSSpeechKit)
[![docs](https://appdevguy.github.io/OSSSpeechKit/badge.svg)](https://appdevguy.github.io/OSSSpeechKit)

OSSSpeechKit was developed to provide easier accessibility options to apps. 

Apple does not make it easy to get the right voice, nor do they provide a simple way of selecting a language or using speech to text. OSSSpeechKit makes the hassle of trying to find the right language go away. 

# Requirements

- Swift 5.0 or higher
- iOS 12.0 or higher
- Cocoapods
- A real device

# Supported Languages

<table class="tg" style="width: 100%;"> <tr> <td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> English - Australian<br>🇦🇺 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Hebrew<br>🇮🇱 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Japanese<br>🇯🇵 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Romanian<br>🇷🇴 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Swedish<br>🇸🇪 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Norsk<br>🇳🇴 </td></tr><tr> <td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Portuguese - Brazilian<br>🇧🇷 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Hindi - Indian<br>🇮🇳 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Korean<br>🇰🇷 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Russian<br>🇷🇺 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Chinese - Taiwanese<br>🇹🇼 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Dutch - Belgium<br>🇧🇪 </td></tr><tr> <td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> French - Canadian<br>🇨🇦 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Hungarian<br>🇭🇺 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Spanish - Mexican<br>🇲🇽 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Arabic - Saudi Arabian<br>🇸🇦 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Thai<br>🇹🇭 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> French<br>🇫🇷 </td></tr><tr> <td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Chinese<br>🇨🇳 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Indonesian<br>🇮🇩 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Norwegian<br>🇳🇴 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Slovakian<br>🇸🇰 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Turkish<br>🇹🇷 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Finnish<br>🇫🇮 </td></tr><tr> <td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Chinese - Hong Kong<br>🇭🇰 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> English - Irish<br>🇮🇪 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Polish<br>🇵🇱 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> English - South African<br>🇿🇦 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> English - United States<br>🇺🇸 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Danish<br>🇩🇰 </td></tr><tr> <td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Czech<br>🇨🇿 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Italian<br>🇮🇹 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Portuguese<br>🇵🇹 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Spanish<br>🇪🇸 </td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> English<br>🇬🇧</td><td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Dutch<br>🇳🇱 </td></tr><tr> <td class="tg-xldj" style="width: 20%; text-align:center; vertical-align: middle;"> Greek<br>🇬🇷 </td></tr></table>

# Features

OSSSpeechKit offers simple **text to speech** and **speech to text** in 37 different languages. 

OSSSpeechKit is built on top of both the [AVFoundation](https://developer.apple.com/documentation/avfoundation) and [Speech](https://developer.apple.com/documentation/speech) frameworks. 

You can achieve text to speech or speech to text in as little as two lines of code. 

The speech will play over the top of other sounds such as music. 

# Installation

OSSSpeechKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'OSSSpeechKit'
```

# Implementation

## Text to Speech
These methods enable you to pass in a string and hear the text played back using.

### Simple

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

### Advanced

```swift
import OSSSpeechKit

.....

// Declare an instance of OSSSpeechKit
let speechKit = OSSSpeech.shared
// Create a voice instance
let newVoice = OSSVoice()
// Set the language
newVoice.language = OSSVoiceEnum.Australian.rawValue
// Set the voice quality
newVoice.quality = .enhanced
// Set the voice of the speech kit
speechKit.voice = newVoice
// Initialise an utterance
let utterance = OSSUtterance(string: "Testing")
// Set the recognition task type 
speechKit.recognitionTaskType = .dictation
// Set volume
utterance.volume = 0.5
// Set rate of speech
utterance.rate = 0.5
// Set the pitch 
utterance.pitchMultiplier = 1.2
// Set speech utterance
speechKit.utterance = utterance
// Ask to speak
speechKit.speakText(text: utterance.speechString)
```


## Speech to Text

Currently speech to text is offered in a very simple format. Starting and stopping of recording is handled by the app. 


### iOS 13 On-Device Speech to Text support is now available as of 0.3.0 🎉

SpeechKit implements delegates to handle the recording authorization, output of text and failure to record.

```swift
speechKit.delegate = self
// Call to start and end recording. 
speechKit.recordVoice()
// Call to end recording
speechKit.endVoiceRecording()
```

It is important that you have included in your `info.plist` the following:

> Privacy - Speech Recognition Usage Description

> Privacy - Microphone Usage Description

Without these, you will not be able to access the microphone nor speech recognition.

### Delegates

Handle returning authentication status to user - primary use is for non-authorized state.
> `func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus)`

When the microphone has finished accepting audio, this delegate will be called with the final best text output.
> `func didFailToCommenceSpeechRecording()`

If the speech recogniser and request fail to set up, this method will be called.
> `func didFinishListening(withText text: String)`

For further information you can [check out the Apple documentation directly.](https://developer.apple.com/documentation/speech/sfspeechrecognizer)

# Other Features

### List all available voices:

```swift
let allLanguages = OSSVoiceEnum.allCases
```

### Get specific voice information:

```swift
// All support languages
let allVoices = OSSVoiceEnum.allCases
// Language details
let languageInformation = allVoices[0].getDetails()
// Flag of country
let flag = allVoices[0].flag
```

The `getDetails()` method returns a struct containing:

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

### Other Info

The `OSSVoiceEnum` contains other methods, such as a hello message, title variable and subtitle variable so you can use it in a list. 

You can also set the speech:

- volume
- pitchMultiplier
- rate

As well as using an `NSAttributedString`.

There are plans to implement flags for each country as well as some more features, such as being able to play the voice if the device is on silent. 

If the language or voice you require is not available, this is either due to:

- Apple have not made it available through their AVFoundation; 
- or the SDK has not been updated to include the newly added voice.

# Important Information

Apple do not make the voice of Siri available for use. 

This kit provides Apple's AVFoundation voices available and easy to use, so you do not need to know all the voice codes, among many other things.

To say things correctly in each language, you need to set the voice to the correct language and supply that languages text; this SDK is not a translator. 

### Code Example:

You wish for you app to use a Chinese voice, you will need to ensure the text being passed in is Chinese. 

_Disclaimer: I do not know how to speak Chinese, I have used Google translate for the Chinese characters._

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

This same principle applies to all other languages such as German, Saudi Arabian, French, etc.. Failing to set the language for the text you wish to be spoken will not sound correct. 

# Contributions and Queries

If you have a question, please create a ticket or email me directly. 

If you wish to contribute, please create a pull request. 

# Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

# Unit Tests

For further examples, please look at the Unit Test class.

# Author

App Dev Guy

<a href="https://stackoverflow.com/users/4008175/app-dev-guy"><img src="https://stackoverflow.com/users/flair/4008175.png" width="208" height="58" alt="profile for App Dev Guy at Stack Overflow, Q&amp;A for professional and enthusiast programmers" title="profile for App Dev Guy at Stack Overflow, Q&amp;A for professional and enthusiast programmers"></a>

# License

OSSSpeechKit is available under the MIT license. See the LICENSE file for more info.
