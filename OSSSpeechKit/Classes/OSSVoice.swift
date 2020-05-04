//  Copyright © 2018-2020 App Dev Guy. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import UIKit
import AVFoundation

/// The voice infor struct ensures that the data structure has conformity and consistency.
public struct OSSVoiceInfo {
    /// The name of the voice; All AVSpeechSynthesisVoice instances have a persons name.
    public var name: String?
    /// The name of the language being used.
    public var language: String?
    /// The language code is what is internationally used in Locale settings.
    public var languageCode: String?
    /// Identifier is a unique bundle url provided by Apple for each AVSpeechSynthesisVoice.
    public var identifier: Any?
}

/// The available system voices.
///
/// The enum is iteratable; access to an array of the enum values can be accessed using:
///
///     OSSVoiceEnum.allCases
///
public enum OSSVoiceEnum: String, CaseIterable {
    /// Australian
    case Australian = "en-AU"
    /// Brazilian
    case Brazilian = "pt-BR"
    /// CanadianFrench
    case CanadianFrench = "fr-CA"
    /// Chinese
    case Chinese = "zh-CH"
    /// ChineseHongKong
    case ChineseHongKong = "zh-HK"
    /// Czech
    case Czech = "cs-CZ"
    /// Danish
    case Danish = "da-DK"
    /// DutchBelgium
    case DutchBelgium = "nl-BE"
    /// DutchNetherlands
    case DutchNetherlands = "nl-NL"
    /// English
    case English = "en-GB"
    /// Finnish
    case Finnish = "fi-FI"
    /// French
    case French = "fr-FR"
    /// German
    case German = "de-DE"
    /// Greek
    case Greek = "el-GR"
    /// Hebrew
    case Hebrew = "he-IL"
    /// Hindi
    case Hindi = "hi-IN"
    /// Hungarian
    case Hungarian = "hu-HU"
    /// Indonesian
    case Indonesian = "id-ID"
    /// IrishEnglish
    case IrishEnglish = "en-IE"
    /// Italian
    case Italian = "it-IT"
    /// Japanese
    case Japanese = "ja-JP"
    /// Korean
    case Korean = "ko-KR"
    /// Mexican
    case Mexican = "es-MX"
    /// Norwegian
    case Norwegian = "no-NO"
    /// Polish
    case Polish = "pl-PL"
    /// Portuguese
    case Portuguese = "pt-PT"
    /// Romanian
    case Romanian = "ro-RO"
    /// Russian
    case Russian = "ru-RU"
    /// SaudiArabian
    case SaudiArabian = "ar-SA"
    /// Slovakian
    case Slovakian = "sk-SK"
    /// South African English
    case SouthAfricanEnglish = "en-ZA"
    /// Spanish
    case Spanish = "es-ES"
    /// Swedish
    case Swedish = "sv-SE"
    /// Taiwanese
    case Taiwanese  = "zh-TW"
    /// Thai
    case Thai = "th-TH"
    /// Turkish
    case Turkish = "tr-TR"
    /// USA English
    case UnitedStatesEnglish = "en-US"
    
    /// Will return specific information about the language as an OSSVoiceInfo object.
    public func getDetails() -> OSSVoiceInfo {
        var voiceInfo: OSSVoiceInfo = OSSVoiceInfo()
        if let voice = AVSpeechSynthesisVoice(language: rawValue) {
            if #available(iOS 9.0, *) {
                voiceInfo.name = voice.name
                voiceInfo.identifier = voice.identifier
            }
            voiceInfo.languageCode = rawValue
            voiceInfo.language = "\(self)"
        }
        return voiceInfo
    }
    
    /// Provides the Enum key itself as a String
    public var title: String {
        return String(describing: self)
    }
    
    /// Demo message is for returning a string in the language that will be read while also providing the name of the voice that Apple have provided.
    public var demoMessage: String {
        var voiceName = ""
        if let name = getDetails().name {
            voiceName = name
        }
        switch self {
        case .SaudiArabian:
            return "\(voiceName) مرحبا اسمي"
        case .Czech:
            return "Dobrý den, jmenuji se \(voiceName)"
        case .Danish:
            return "Hej, mit navn er \(voiceName)"
        case .German:
            return "Hallo, Ich heisse \(voiceName)"
        case .Greek:
            return "Γεια το όνομά μου είναι \(voiceName)"
        case .Australian:
            return "Hello, my name is \(voiceName)"
        case .English:
            return "Hello, my name is \(voiceName)"
        case .IrishEnglish:
            return "Hello, my name is \(voiceName)"
        case .UnitedStatesEnglish:
            return "Hello, my name is \(voiceName)"
        case .SouthAfricanEnglish:
            return "Hello, my name is \(voiceName)"
        case .Spanish:
            return "Hola, mi nombre es \(voiceName)"
        case .Mexican:
            return "Hola, mi nombre es \(voiceName)"
        case .Finnish:
            return "Hei, minun nimeni on \(voiceName)"
        case .CanadianFrench:
            return "Bonjour, mon nom est \(voiceName)"
        case .French:
            return "Bonjour, mon nom est \(voiceName)"
        case .Hebrew:
            return "\(voiceName)שלום שמי הוא"
        case .Hindi:
            return "नमस्ते मेरा नाम है \(voiceName)"
        case .Hungarian:
            return "Helló, az én nevem \(voiceName)"
        case .Indonesian:
            return "Halo, namaku adalah \(voiceName)"
        case .Italian:
            return "Ciao, il mio nome è \(voiceName)"
        case .Japanese:
            return "こんにちは、私の名前は \(voiceName)"
        case .Korean:
            return "안녕 내 이름은 \(voiceName)"
        case .DutchBelgium:
            return "Hallo, mijn naam is \(voiceName)"
        case .DutchNetherlands:
            return "Hallo, mijn naam is \(voiceName)"
        case .Norwegian:
            return "Hei, mitt navn er \(voiceName)"
        case .Polish:
            return "Cześć, mam na imię \(voiceName)"
        case .Brazilian:
            return "Olá meu nome é \(voiceName)"
        case .Portuguese:
            return "Olá meu nome é \(voiceName)"
        case .Romanian:
            return "Buna numele meu este \(voiceName)"
        case .Russian:
            return "Привет меня зовут \(voiceName)"
        case .Slovakian:
            return "Ahoj volám sa \(voiceName)"
        case .Swedish:
            return "Hej mitt namn är \(voiceName)"
        case .Thai:
            return "สวัสดีฉันชื่อ \(voiceName)"
        case .Turkish:
            return "Merhaba benim adım \(voiceName)"
        case .Chinese:
            return "你好我的名字是 \(voiceName)"
        case .ChineseHongKong:
            return "你好我的名字是 \(voiceName)"
        case .Taiwanese:
            return "你好我的名字是 \(voiceName)"
        }
    }
    
    /// The flag for the selected language.
    ///
    /// You can supply your own flag image, provided is has the same name (.rawValue) as the image in the pod assets.
    ///
    /// If no image is found in the application bundle, the image from the SDK bundle will be provided.
    public var flag: UIImage? {
        if let mainBundleImage = UIImage(named: rawValue, in: Bundle.main, compatibleWith: nil) {
            return mainBundleImage
        }
        return UIImage(named: rawValue, in: Bundle.getResourcesBundle(), compatibleWith: nil)
    }
}

/** OSSVoice overides some of the properties provided to enable setting as well as getting.

 The purpose of this class is so that a single voice object can be set and reused through the Speech instance. Properties have been overriden for this very purpose.

 Setting the voice quality to be ```.enhanced``` instead of ```.default``` and the resetting of language after creation is not enabled in the AV provided API instance of AVSpeechSynthesisVoice.
 
 - Note: If init() is called, the default quality of OSSVoice will us "default" and the language will be "OSSVoiceEnum.UnitedStatesEnglish".
*/
@available(iOS 9.0, *)
public class OSSVoice: AVSpeechSynthesisVoice {
    
    // MARK: - Private Properties
    
    private var voiceQuality: AVSpeechSynthesisVoiceQuality = .default
    private var voiceLanguage: String = OSSVoiceEnum.UnitedStatesEnglish.rawValue
    private var voiceTypeValue: OSSVoiceEnum = .UnitedStatesEnglish
    
    /// You have access to set the voice quality or use the default which is set to .default
    override public var quality: AVSpeechSynthesisVoiceQuality {
        get {
            return voiceQuality
        }
        set {
            voiceQuality = newValue
        }
    }
    
    /// Language offers a get and set. The default value is United States English.
    override public var language: String {
        get {
            return voiceLanguage
        }
        set {
            voiceLanguage = newValue
            if let valueEnum = OSSVoiceEnum(rawValue: newValue) {
                voiceTypeValue = valueEnum
            }            
        }
    }
    
    /// Returns the current voice type enum to allow for obtining details.
    public var voiceType: OSSVoiceEnum {
        get {
            return voiceTypeValue
        }
    }
    
    /// If this init is used, defaults will be used.
    ///
    /// This method will set default values on the language and quality of voice.
    ///
    /// Langague defaults to United States English.
    ///
    /// Quality defaults to .default.
    public override init() {
        super.init()
        commonInit()
    }
    
    /// This init method is required as it sets the voice quality and language in order to speak the text passed in.
    public init?(quality: AVSpeechSynthesisVoiceQuality, language: OSSVoiceEnum) {
        super.init()
        voiceTypeValue = language
        voiceLanguage = language.rawValue
        voiceQuality = quality
    }
    
    /// Required: Do not recommend using.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        return nil
    }
    
    /// Used as a fail-safe should the custom init method not be used.
    ///
    /// This method will set default values on the language and quality of voice.
    ///
    /// Langague defaults to United States English.
    ///
    /// Quality defaults to .default.
    private func commonInit() {
        // Set the default values
        voiceTypeValue = OSSVoiceEnum.UnitedStatesEnglish
        voiceLanguage = OSSVoiceEnum.UnitedStatesEnglish.rawValue
        voiceQuality = .default
    }
}
