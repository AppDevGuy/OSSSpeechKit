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

/// All of the possible error types that can be thrown by OSSSpeechKit
public enum OSSSpeechKitErrorType: Int {
    case noMicrophoneAccess = -1
    case invalidUtterance = -2
    case invalidText = -3
    case invalidVoice = -4
    case invalidSpeechRequest = -5
    case invalidAudioEngine = -6
    case recogniserUnavailble = -7
    
    var errorMessage: String {
        switch self {
        case .noMicrophoneAccess:
            return "Access to the microphone is unavailable."
        case .invalidUtterance:
            return "The utterance is invalid. Please ensure you have created one or passed in valid text to speak."
        case .invalidText:
            return "The text provided to the utterance is either empty or has not been set."
        case .invalidVoice:
            return "In order to speak text, a valid voice is required.."
        case .invalidSpeechRequest:
            return "The speech request is invalid. Please ensure the string provided contains text."
        case .invalidAudioEngine:
            return "The audio engine is unavailable. Please try again soon."
        case .recogniserUnavailble:
            return "The Speech Recognition service is currently unavailable."
        }
    }
    
    var errorRequestType: String {
        switch self {
        case .noMicrophoneAccess,
            .invalidAudioEngine:
            return "Recording"
        case .invalidUtterance:
            return "Speech or Recording"
        case .invalidText,
             .invalidVoice,
             .invalidSpeechRequest,
             .recogniserUnavailble:
            return "Speech"
        }
    }
    
    var error: Error? {
        let err = NSError(domain: "au.com.appdevguy.ossspeechkit",
                          code: self.rawValue,
                          userInfo: [
                            "message": self.errorMessage,
                            "request": self.errorRequestType
            ]
        )
        return err
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
    /// Method for real time recpetion of translated text.
    func didCompleteTranslation(withText text: String)
    /// Error handling function.
    func didFailToProcessRequest(withError error: Error?)
}

/// The speech recognition task type.
public enum OSSSpeechRecognitionTaskType: Int {
    /// Undefined is the standard recognition type and allows the system to decide which type of task is best.
    case undefined = 0
    /// Use captured speech for text entry purposes.
    ///
    /// Use this when doing a similar task that of the keyboard voice to text function.
    case dictation = 1
    /// Use this for short speechs such as "Yes", "No", "Thanks", etc.
    case confirmation = 2
    /// Use this short speechs that have specific words or terms.
    case search = 3
    
    /// Returns a speech recognition hint based on the enum value.
    public var taskType: SFSpeechRecognitionTaskHint {
        switch self {
        case .undefined:
            return .unspecified
        case .dictation:
            return .dictation
        case .confirmation:
            return .confirmation
        case .search:
            return .search
        }
    }
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
    
    /// Speech recognition variable to determine if recognition should use on device capabilities if available
    ///
    /// Not all devices support on device speech recognition and only devices operation with iOS 13 or higher support it.
    ///
    /// This var should be set to true unless you wish to have network recognition.
    ///
    /// On device recognition offers many benefits such as working without network connectivity,
    /// no data costs and longer recording-to-transcription.
    public var shouldUseOnDeviceRecognition = true
    
    /// The task type by default is undefined.
    /// Changing the task type will change how speech recognition performs.
    public var recognitionTaskType = OSSSpeechRecognitionTaskType.undefined
    
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
    public func speakText(_ text: String? = nil) {
        if !self.utteranceIsValid() {
            guard let speechText = text else {
                self.debugLog(object: self, message: "Text is empty or nil. Please confirm text has been passed in.")
                self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidUtterance.error)
                return
            }
            // Handle empty text gracefully.
            if speechText.isEmpty {
                self.debugLog(object: self, message: "Text is empty or nil. Please confirm text has been passed in.")
                self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidUtterance.error)
                return
            }
            self.utterance = OSSUtterance(string: speechText)
        }
        if let speechText = text, !speechText.isEmpty {
            self.utterance?.speechString = speechText
        }
        guard let _ = self.utterance?.speechString else {
            self.debugLog(object: self, message: "Text is empty or nil. Please confirm text has been passed in.")
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidUtterance.error)
             return
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
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidText.error)
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
        // While unlikely to be invalid or null, safety first.
        guard let validUtterance = self.utterance else {
            self.debugLog(object: self, message: "No valid utterance.")
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidUtterance.error)
            return
        }
        var speechVoice = OSSVoice()
        if let aVoice = self.voice {
            speechVoice = aVoice
        }
        let validString = validUtterance.speechString
        if validString.isEmpty {
            self.debugLog(object: self, message: "No valid utterance string, please ensure you are passing a string to your speak call.")
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidText.error)
            return
        }
        // Utterance must be an original object in order to be spoken. We redefine an new instance of Utterance each time using the values in the existing utterance.
        let newUtterance = AVSpeechUtterance(string: validString)
        newUtterance.rate = validUtterance.rate
        newUtterance.pitchMultiplier = validUtterance.pitchMultiplier
        newUtterance.volume = validUtterance.volume
        newUtterance.voice = speechVoice
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
        cancelRecording()
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
        guard let task = recognitionTask else {
                        self.debugLog(object: self, message: "No valid voice recognition task.")
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidSpeechRequest.error)
            return
        }
        guard let engine = audioEngine else {
            self.debugLog(object: self, message: "No audio recording session is active.")
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
            return
        }
        if !engine.isRunning {
            self.debugLog(object: self, message: "No audio recording session is active.")
            return
        }
        guard let voiceRequest = request else {
            self.debugLog(object: self, message: "No valid voice request.")
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidSpeechRequest.error)
            return
        }
        engine.stop()
        voiceRequest.endAudio()
        let node = engine.inputNode
        node.removeTap(onBus: 0)
        // Remove from memory
        audioEngine = nil
        request = nil
        task.finish()
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
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
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
            self.delegate?.didFailToCommenceSpeechRecording()
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
            return
        }
        guard let recogniser = SFSpeechRecognizer() else {
            self.delegate?.didFailToCommenceSpeechRecording()
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidSpeechRequest.error)
            return
        }
        if !recogniser.isAvailable {
            self.delegate?.didFailToCommenceSpeechRecording()
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.recogniserUnavailble.error)
            return
        }
        speechRecognizer = recogniser
        if let audioRequest = request, let speechRecog = speechRecognizer {
            if #available(iOS 13, *) {
                speechRecog.supportsOnDeviceRecognition = shouldUseOnDeviceRecognition
            }
            speechRecog.delegate = self
            speechRecog.defaultTaskHint = recognitionTaskType.taskType
            recognitionTask = speechRecog.recognitionTask(with: audioRequest, delegate: self)
        } else {
            self.delegate?.didFailToCommenceSpeechRecording()
            self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidSpeechRequest.error)
        }
    }
}

/// Extension to handle the SFSpeechRecognitionTaskDelegate and SFSpeechRecognizerDelegate methods.
extension OSSSpeech: SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate {
    
    // MARK: - SFSpeechRecognitionTaskDelegate Methods
    
    /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("Finished successfully? \(successfully)")
        recognitionTask = nil
        self.delegate?.didFinishListening(withText: self.spokenText)
        self.setSession(isRecording: false)
    }
    
    /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print("Hypothesized Transcription: \(transcription.formattedString)")
        self.delegate?.didCompleteTranslation(withText: transcription.formattedString)
    }
    
    /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
//        print("The recognition: \(recognitionResult)")
//        print("The transcriptions: \(recognitionResult.transcriptions)")
        print("The best transcriptions: \(recognitionResult.bestTranscription.formattedString)")
        self.spokenText = recognitionResult.bestTranscription.formattedString
    }
    
    public func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        print("Speech detected")
    }
    
    public func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        print("Speech task finished reading audio")
    }
    
    // MARK: - SFSpeechRecognizerDelegate Methods
    
    /// Docs available by Google searching for SFSpeechRecognizerDelegate
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Availability did change.")
    }
    
    // MARK: - Public Debug Output
    
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
