//
//  OSSUtterance.swift
//  OSSSpeechKit
//
//  Created by Sean Smith on 29/12/18.
//  Copyright © 2018 App Dev Guy. All rights reserved.
//

import AVFoundation

/// OSSUtterance is a wrapper of the AVSpeechUtterance class.
///
/// The OSSUtterance offers special overrides for strings which are usually set once objects.
///
/// As the developer, you can override the `volume`, `rate` and `pitchMultiplier` should you wish to.
public class OSSUtterance: AVSpeechUtterance {
    
    // MARK: - Variables
    private var stringToSpeak: String = ""
    private var attributedStringToSpeak: NSAttributedString = NSAttributedString(string: "")
    
    /// The speechString can be a constant value or changed as frequently as you wish.
    ///
    /// The Speech String is what will be read out.
    /// Default value in an empty string.
    override public var speechString: String {
        get {
            if stringToSpeak.isEmpty {
                if !attributedSpeechString.string.isEmpty {
                    return attributedSpeechString.string
                }
            }
            return stringToSpeak
        }
        set {
            self.stringToSpeak = newValue
        }
    }
    
    /// The attributedSpeechString can be a constant value or changed as frequently as you wish.
    ///
    /// The Attributed Speech String is what will be read out if no speechString is set.
    /// Default value in an empty string.
    override public var attributedSpeechString: NSAttributedString {
        get {
            return self.attributedStringToSpeak
        }
        set {
            self.attributedStringToSpeak = newValue
        }
    }
    
    // MARK: - Lifecycle
    
    private override init() {
        super.init()
    }
    
    /// Init method which will set the speechString value.
    override init(string: String) {
        super.init(string: string)
        self.speechString = string
        self.attributedSpeechString = NSAttributedString(string: string)
        self.commonInit()
    }
    
    /// Init method which will set the attributedSpeechString value.
    override init(attributedString: NSAttributedString) {
        super.init(attributedString: attributedString)
        self.attributedSpeechString = attributedString
        self.speechString = attributedString.string
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    /// Common init is used for testing purposes only.
    private func commonInit() {
        // Init default values
        self.rate = AVSpeechUtteranceDefaultSpeechRate
        self.pitchMultiplier = 1.0
        self.volume = 1.0
        self.voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
    }
}
