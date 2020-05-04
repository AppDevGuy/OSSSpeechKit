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
            return stringToSpeak
        }
        set {
            stringToSpeak = newValue
            attributedStringToSpeak = NSAttributedString(string: newValue)
        }
    }
    
    /// The attributedSpeechString can be a constant value or changed as frequently as you wish.
    ///
    /// The Attributed Speech String is what will be read out if no speechString is set.
    /// Default value in an empty string.
    override public var attributedSpeechString: NSAttributedString {
        get {
            return attributedStringToSpeak
        }
        set {
            stringToSpeak = newValue.string
            attributedStringToSpeak = newValue
        }
    }
    
    // MARK: - Lifecycle
    
    public override init() {
        super.init(string: "ERROR")
        debugLog(object: self, message: "ERROR: You must use the `init(string:)` or `init(attributedString:` methods.")
        speechString = "ERROR"
        attributedSpeechString = NSAttributedString(string: "ERROR")
        commonInit()
    }
    
    /// Init method which will set the speechString value.
    public override init(string: String) {
        super.init(string: string)
        speechString = string
        attributedSpeechString = NSAttributedString(string: string)
        commonInit()
    }
    
    /// Init method which will set the attributedSpeechString value.
    public override init(attributedString: NSAttributedString) {
        super.init(attributedString: attributedString)
        attributedSpeechString = attributedString
        speechString = attributedString.string
        commonInit()
    }
    
    /// Required. Do not recommend using.
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        return nil
    }
    
    // MARK: - Private Methods
    
    /// Common init is used for testing purposes only.
    private func commonInit() {
        // Init default values
        rate = AVSpeechUtteranceDefaultSpeechRate
        pitchMultiplier = 1.0
        volume = 1.0
        voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
    }
}
