//
//  OSSVoice.swift
//  OSSSpeechKit
//
//  Created by Sean Smith on 29/12/18.
//  Copyright © 2018 App Dev Guy. All rights reserved.
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
    case SaudiArabian = "ar-SA"
    case Czech = "cs-CZ"
    case Danish = "da-DK"
    case German = "de-DE"
    case Greek = "el-GR"
    case Australian = "en-AU"
    case English = "en-GB"
    case IrishEnglish = "en-IE"
    case UnitedStatesEnglish = "en-US"
    case SouthAfricanEnglish = "en-ZA"
    case Spanish = "es-ES"
    case Mexican = "es-MX"
    case Finnish = "fi-FI"
    case CanadianFrench = "fr-CA"
    case French = "fr-FR"
    case Hebrew = "he-IL"
    case Hindi = "hi-IN"
    case Hungarian = "hu-HU"
    case Indonesian = "id-ID"
    case Italian = "it-IT"
    case Japanese = "ja-JP"
    case Korean = "ko-KR"
    case DutchBelgium = "nl-BE"
    case DutchNetherlands = "nl-NL"
    case Norwegian = "no-NO"
    case Polish = "pl-PL"
    case Brazilian = "pt-BR"
    case Portuguese = "pt-PT"
    case Romanian = "ro-RO"
    case Russian = "ru-RU"
    case Slovakian = "sk-SK"
    case Swedish = "sv-SE"
    case Thai = "th-TH"
    case Turkish = "tr-TR"
    case Chinese = "zh-CH"
    case ChineseHongKong = "zh-HK"
    case Taiwanese  = "zh-TW"
    
    /// Will return specific information about the language as an OSSVoiceInfo object.
    public func getDetails() -> OSSVoiceInfo {
        var voiceInfo: OSSVoiceInfo = OSSVoiceInfo()
        if let voice = AVSpeechSynthesisVoice(language: self.rawValue) {
            if #available(iOS 9.0, *) {
                voiceInfo.name = voice.name
                voiceInfo.identifier = voice.identifier
            } else {
                // Fallback on earlier versions
                voiceInfo.identifier = "unavailable"
                voiceInfo.identifier = "unavailable"
            }
            voiceInfo.languageCode = self.rawValue
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
        if let name = self.getDetails().name {
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
    private var voiceLanguage: String = "en-US"
    private var voiceTypeValue: OSSVoiceEnum = .UnitedStatesEnglish
    
    /// You have access to set the voice quality or use the default which is set to .default
    override public var quality: AVSpeechSynthesisVoiceQuality {
        get {
            return self.voiceQuality
        }
        set {
            self.voiceQuality = newValue
        }
    }
    
    /// Language offers a get and set. The default value is United States English.
    override public var language: String {
        get {
            return voiceLanguage
        }
        set {
            self.voiceLanguage = newValue
        }
    }
    
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
        self.commonInit()
    }
    
    /// This init method is required as it sets the voice quality and language in order to speak the text passed in.
    public init?(quality: AVSpeechSynthesisVoiceQuality, language: OSSVoiceEnum) {
        super.init()
        self.voiceTypeValue = language
        self.language = language.rawValue
        self.quality = quality
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.voiceTypeValue = OSSVoiceEnum.UnitedStatesEnglish
        self.language = OSSVoiceEnum.UnitedStatesEnglish.rawValue
        self.quality = .default
    }
}
