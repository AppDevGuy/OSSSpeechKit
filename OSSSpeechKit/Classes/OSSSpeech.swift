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

/// The authorization status of the Microphone and recording, imitating the native `SFSpeechRecognizerAuthorizationStatus`
public enum OSSSpeechAuthorizationStatus: Int {
    /// The app's authorization status has not yet been determined.
    case notDetermined
    /// The user denied your app's request to perform speech recognition.
    case denied
    /// The device prevents your app from performing speech recognition.
    case restricted
    /// The user granted your app's request to perform speech recognition.
    case authorized
    
    /// A public message that can be displayed to the user.
    public var message: String {
        switch self {
        case .notDetermined:
            return "The app's authorization status has not yet been determined."
        case .denied:
            return "The user denied your app's request to perform speech recognition."
        case .restricted:
            return "The device prevents your app from performing speech recognition."
        case .authorized:
            return "The user granted your app's request to perform speech recognition."
        }
    }
}

/// Delegate to handle events such as failed authentication for microphone among many more.
public protocol OSSSpeechDelegate: class {
    /// When the microphone has finished accepting audio, this delegate will be called with the final best text output.
    func didFinishListening(withText text: String)
    /// Handle returning authentication status to user - primary use is for non-authorized state.
    func authorizationToMicrophone(withAuthentication type: OSSSpeechAuthorizationStatus)
    /// If the speech recogniser and request fail to set up, this method will be called.
    func didFailToCommenceSpeechRecording()
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
    private var speechRecognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
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
    
    // MARK: - Public Voice Recording Methods
    
    /// Record and recognise speech
    ///
    /// This method will check to see if user is authorised to record. If they are, the recording will proceed.
    ///
    /// Upon checking the authorisation and being registered successful, a check to determine if a recording session is active will be made and any active session will be cancelled.
    public func recordVoice() {
        getMicroPhoneAuthorization()
    }
    
    /// End recording of speech session if one exists.
    public func endVoiceRecording() {
        if let engine = self.audioEngine {
            if engine.isRunning {
                cancelRecording()
            }
        }
    }
    
    // MARK: - Private Voice Recording
    
    private func getMicroPhoneAuthorization() {
        SFSpeechRecognizer.requestAuthorization {
            [unowned self] (authStatus) in
            let status = OSSSpeechAuthorizationStatus(rawValue: authStatus.rawValue)
            switch authStatus {
            case .authorized:
                OperationQueue.main.addOperation {
                    self.recordAndRecognizeSpeech()
                    self.delegate?.authorizationToMicrophone(withAuthentication: status!)
                }
                break
            default:
                OperationQueue.main.addOperation {
                    self.delegate?.authorizationToMicrophone(withAuthentication: status!)
                }
                break
            }
        }
    }
    
    private func cancelRecording() {
        guard let engine = audioEngine, let voiceRequest = request else {
            self.debugLog(object: self, message: "No audio recording session is active.")
            return
        }
        engine.stop()
        voiceRequest.endAudio()
        recognitionTask?.cancel()
        let node = engine.inputNode
        node.removeTap(onBus: 0)
        recognitionTask?.finish()
        // Remove from memory
        audioEngine = nil
        request = nil
        self.setSession(isRecording: false)
        self.delegate?.didFinishListening(withText: self.spokenText)
    }
    
    private func recordAndRecognizeSpeech() {
        if let engine = self.audioEngine {
            if engine.isRunning {
                cancelRecording()
            }
        }
        self.setSession(isRecording: true)
        request = SFSpeechAudioBufferRecognitionRequest()
        audioEngine = AVAudioEngine()
        let identifier = voice?.voiceType.rawValue ?? OSSVoiceEnum.UnitedStatesEnglish.rawValue
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: identifier))
        guard let engine = audioEngine else {
            self.debugLog(object: self, message: "The audio engine is nil.")
            return
        }
        let node = engine.inputNode
        let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        node.installTap(onBus: 0, bufferSize: 8192, format: recordingFormat) { (buffer, audioTime) in
            self.request?.append(buffer)
        }
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print("Error starting audio engine: \(error)")
            self.delegate?.didFailToCommenceSpeechRecording()
            return
        }
        guard let recogniser = SFSpeechRecognizer() else {
            print("No speech recogniser")
            self.delegate?.didFailToCommenceSpeechRecording()
            return
        }
        if !recogniser.isAvailable {
            print("No recogniser available right now.")
            self.delegate?.didFailToCommenceSpeechRecording()
            return
        }
        if let audioRequest = request, let speechRecog = speechRecognizer {
            speechRecog.defaultTaskHint = .unspecified
            recognitionTask = speechRecog.recognitionTask(with: audioRequest, delegate: self)
        } else {
            self.delegate?.didFailToCommenceSpeechRecording()
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
