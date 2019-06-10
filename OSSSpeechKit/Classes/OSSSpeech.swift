//
//  OSSSpeech.swift
//  OSSSpeechKit
//
//  Created by Sean Smith on 29/12/18.
//  Copyright © 2018 App Dev Guy. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

public protocol OSSSpeechDelegate: class {
    func didFinishListening(withText text: String)
}

/// Speech is the primary interface. To use, set the voice and then call `.speak(string: "your string")`
public class OSSSpeech: NSObject {
    
    // MARK: - Private Properties
    
    /// An object that produces synthesized speech from text utterances and provides controls for monitoring or controlling ongoing speech.
    private var speechSynthesizer: AVSpeechSynthesizer!
    
    // MARK: - Variables
    
    /// Delegate allows for the recieving of spoken events.
    public weak var delegate: OSSSpeechDelegate?
    
    /// An object that allows overriding the default AVVoice options.
    public var voice: OSSVoice?
    
    /// The object used to enable translation of strings to synthsized voice.
    public var utterance: OSSUtterance?
    
    /// An AVAudioSession that ensure volume controls are correct in various scenarios
    private let session = AVAudioSession.sharedInstance()
    
    // Voice to text
    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    private let localVoice = OSSVoiceEnum.Australian.rawValue
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var spokenText: String = ""
    
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
        // Ensure volume is correct each time
        self.setSession(isRecording: false)
        self.speechSynthesizer.speak(newUtterance)
    }
    
    private func setSession(isRecording: Bool) {
        let category: AVAudioSession.Category = isRecording ? .playAndRecord : .playback
        try! self.session.setCategory(category, options: .duckOthers)
        try! self.session.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    // MARK: - Voice Recording
    
    private func checkState() {
        switch recognitionTask!.state {
        case .starting:
            print("Starting...")
            break
        case .running:
            print("Running...")
            break
        case .finishing:
            print("Finish...")
            break
        case .canceling:
            print("Cancel...")
            break
        case .completed:
            print("Complete...")
            break
        @unknown default:
            print("Default...")
            break
        }
    }
    
    private func cancelRecording() {
        audioEngine!.stop()
        request.endAudio()
        recognitionTask?.cancel()
        let node = audioEngine!.inputNode
        node.removeTap(onBus: 0)
        recognitionTask?.finish()
        audioEngine = nil
        self.checkState()
        self.setSession(isRecording: false)
        self.delegate?.didFinishListening(withText: self.spokenText)
    }
    
    private func recordAndRecognizeSpeech() {
        if let engine = audioEngine {
            if engine.isRunning {
                cancelRecording()
                return
            }
        }
        self.setSession(isRecording: true)
        request = SFSpeechAudioBufferRecognitionRequest()
        audioEngine = AVAudioEngine()
        let identifier = voice?.voiceType.rawValue ?? OSSVoiceEnum.UnitedStatesEnglish.rawValue
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: identifier))
        let node = audioEngine!.inputNode
        let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        node.installTap(onBus: 0, bufferSize: 8192, format: recordingFormat) { (buffer, audioTime) in
            self.request.append(buffer)
        }
        audioEngine!.prepare()
        do {
            try audioEngine!.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
        guard let recogniser = SFSpeechRecognizer() else {
            print("No speech recogniser")
            return
        }
        if !recogniser.isAvailable {
            print("No recogniser available right now.")
            return
        }
        speechRecognizer?.defaultTaskHint = .unspecified
        recognitionTask = speechRecognizer?.recognitionTask(with: request, delegate: self)
    }
    
    /// Record and recognise speech
    ///
    /// This method will check to see if user is authorised to record. If they are, the recording will proceed.
    /// If they are not.
    public func recordVoice() {
        SFSpeechRecognizer.requestAuthorization {
            [unowned self] (authStatus) in
            switch authStatus {
            case .authorized:
                self.recordAndRecognizeSpeech()
                break
            case .denied:
                print("Speech recognition authorization denied")
                break
            case .restricted:
                print("Not available on this device")
                break
            case .notDetermined:
                print("Not determined")
                break
            @unknown default:
                print("Unknown/Not determined")
                break
            }
        }
    }
}

extension OSSSpeech: SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate {
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("Finished successfully? \(successfully)")
    }
    
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print("Transcription: \(transcription.formattedString)")
        self.spokenText = transcription.formattedString
    }
    
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print("The recognition: \(recognitionResult)")
        print("The transcriptions: \(recognitionResult.transcriptions)")
        print("The best transcriptions: \(recognitionResult.bestTranscription.formattedString)")
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Availability did change.")
    }
    
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
