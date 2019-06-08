//
//  OSSSpeech.swift
//  OSSSpeechKit
//
//  Created by Sean Smith on 29/12/18.
//  Copyright © 2018 App Dev Guy. All rights reserved.
//

import UIKit
import AVFoundation

/// Speech is the primary interface. To use, set the voice and then call `.speak(string: "your string")`
public class OSSSpeech: NSObject {
    
    // MARK: - Private Properties
    
    /// An object that produces synthesized speech from text utterances and provides controls for monitoring or controlling ongoing speech.
    private var speechSynthesizer: AVSpeechSynthesizer!
    
    // MARK: - Variables
    
    /// An object that allows overriding the default AVVoice options.
    public var voice: OSSVoice?
    
    /// The object used to enable translation of strings to synthsized voice.
    public var utterance: OSSUtterance?
    
    // MARK: - Lifecycle
    
    private override init(){
        self.speechSynthesizer = AVSpeechSynthesizer()
    }
    
    private static let sharedInstance: OSSSpeech = {
        return OSSSpeech()
    }()
    
    /// A singleton object to ensure conformity accross the application it is used in.
    public class var shared: OSSSpeech {
        return sharedInstance
    }
    
    // MARK: - Public Methods
    
    /// Pass in a string to speak.
    /// This will set the speechString on the utterance.
    /// - Parameter text: An String object.
    public func speakText(text: String) {
        // Handle empty text gracefully.
        if text.isEmpty {
            self.debugLog(object: self, message: "Text is empty or nil. Please confirm text has been passed in.")
            return
        }
        if !self.utteranceIsValid() {
            // Initialize default utterance
            self.utterance = OSSUtterance(string: text)
        }
        if self.utterance!.speechString != text {
           self.utterance!.speechString = text
        }
        self.speak()
    }
    
    /// Pass in an attributed string to speak.
    /// This will set the attributed string on the utterance.
    /// - Parameter attributedText: An NSAttributedString object.
    public func speakAttributedText(attributedText: NSAttributedString) {
        // Handle empty text gracefully.
        if attributedText.string.isEmpty {
            self.debugLog(object: self, message: "Attributed text is empty or nil. Please confirm text has been passed in.")
            return
        }
        if !self.utteranceIsValid() {
            // Initialize default utterance
            self.utterance = OSSUtterance(attributedString: attributedText)
        }
        if self.utterance!.attributedSpeechString.string != attributedText.string {
            self.utterance!.attributedSpeechString = attributedText
        }
        self.speak()
    }
    
    // MARK: - Private Methods
    
    private func voiceIsValid() -> Bool {
        guard let _ = self.voice else {
            if self.utteranceIsValid() {
                guard let _ = self.utterance!.voice else {
                    self.debugLog(object: self, message: "No valid utterance voice.")
                    return false
                }
                return true
            }
            self.debugLog(object: self, message: "No valid voice.")
            return false
        }
        return true
    }

    private func utteranceIsValid() -> Bool {
        guard let _ = self.utterance else {
            self.debugLog(object: self, message: "No valid utterance.")
            return false
        }
        return true
    }
    
    private func speak() {
        if !self.voiceIsValid() {
            self.voice = OSSVoice()
        }
        // While unlikely to be invalid or null, safety first.
        guard let validUtterance = self.utterance else {
            self.debugLog(object: self, message: "No valid utterance.")
            return
        }
        let validString = validUtterance.speechString
        if validString.isEmpty {
            self.debugLog(object: self, message: "No valid utterance string, please ensure you are passing a string to your speak call.")
            return
        }
        // Utterance must be an original object in order to be spoken. We redefine an new instance of Utterance each time using the values in the existing utterance.
        let newUtterance = AVSpeechUtterance(string: validString)
        newUtterance.rate = validUtterance.rate
        newUtterance.pitchMultiplier = validUtterance.pitchMultiplier
        newUtterance.volume = validUtterance.volume
        newUtterance.voice = self.voice!
        self.speechSynthesizer.speak(newUtterance)
    }
    
}

extension OSSSpeech {
    /// Method outputs a debug statement containing necessary information to resolve issues.
    ///
    ///  Only works with debug/dev builds.
    ///
    ///  - Parameters:
    ///     - object: Any object type
    ///     - functionName: Automatically populated by the application
    ///     - fileName: Automatically populated by the application
    ///     - lineNumber: Automatically populated by the application
    ///     - message: The message you wish to output.
    public func debugLog(object: Any, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, message: String) {
        #if DEBUG
        let className = (fileName as NSString).lastPathComponent
        print("\n\n******************\tBegin Debug Log\t******************\n\n\tClass: <\(className)>\n\tFunction: \(functionName)\n\tLine: #\(lineNumber)\n\tObject: \(object)\n\tLog Message: \(message)\n\n******************\tEnd Debug Log\t******************\n\n")
        #endif
    }
}
