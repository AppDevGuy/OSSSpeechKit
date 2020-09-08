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
import Speech

/// The authorization status of the Microphone and recording, imitating the native `SFSpeechRecognizerAuthorizationStatus`
public enum OSSSpeechKitAuthorizationStatus: Int {
    /// The app's authorization status has not yet been determined.
    case notDetermined = 0
    /// The user denied your app's request to perform speech recognition.
    case denied = 1
    /// The device prevents your app from performing speech recognition.
    case restricted = 2
    /// The user granted your app's request to perform speech recognition.
    case authorized = 3
    
    /// A public message that can be displayed to the user.
    public var message: String {
        switch self {
        case .notDetermined:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitAuthorizationStatus_messageNotDetermined", defaultValue:"The app's authorization status has not yet been determined.")
        case .denied:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitAuthorizationStatus_messageDenied", defaultValue:"The user denied your app's request to perform speech recognition.")
        case .restricted:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitAuthorizationStatus_messageRestricted", defaultValue:"The device prevents your app from performing speech recognition.")
        case .authorized:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitAuthorizationStatus_messageAuthorized", defaultValue:"The user granted your app's request to perform speech recognition.")
        }
    }
}

/// All of the possible error types that can be thrown by OSSSpeechKit
public enum OSSSpeechKitErrorType: Int {
    /// No microphone access
    case noMicrophoneAccess = -1
    /// An invalid utterance.
    case invalidUtterance = -2
    /// Invalid text - usually an empty string.
    case invalidText = -3
    /// The voice type is invalid.
    case invalidVoice = -4
    /// Speech recognition request is invalid.
    case invalidSpeechRequest = -5
    /// The audio engine is invalid.
    case invalidAudioEngine = -6
    /// Voice recognition is unavailable.
    case recogniserUnavailble = -7
    
    /// The OSSSpeechKit error message string.
    ///
    /// The error message strings can be altered in the Localized strings file.
    public var errorMessage: String {
        switch self {
        case .noMicrophoneAccess:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_messageNoMicAccess", defaultValue:"Access to the microphone is unavailable.")
        case .invalidUtterance:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_messageInvalidUtterance", defaultValue:"The utterance is invalid. Please ensure you have created one or passed in valid text to speak.")
        case .invalidText:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_messageInvalidText", defaultValue:"The text provided to the utterance is either empty or has not been set.")
        case .invalidVoice:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_messageInvalidVoice", defaultValue:"In order to speak text, a valid voice is required.")
        case .invalidSpeechRequest:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_messageInvalidSpeechRequest", defaultValue:"The speech request is invalid. Please ensure the string provided contains text.")
        case .invalidAudioEngine:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_messageInvalidAudioEngine", defaultValue:"The audio engine is unavailable. Please try again soon.")
        case .recogniserUnavailble:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_messageRecogniserUnavailable", defaultValue:"The Speech Recognition service is currently unavailable.")
        }
    }
    
    /// The highlevel type of error that occured.
    ///
    /// A String will be used in the OSSSpeechKitErrorType error: Error? that is returned when an exception is thrown.
    public var errorRequestType: String {
        switch self {
        case .noMicrophoneAccess,
            .invalidAudioEngine:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_requestTypeNoMicAccess", defaultValue:"Recording")
        case .invalidUtterance:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_requestTypeInvalidUtterance", defaultValue:"Speech or Recording")
        case .invalidText,
             .invalidVoice,
             .invalidSpeechRequest,
             .recogniserUnavailble:
            return OSSSpeechUtility().getString(forLocalizedName:"OSSSpeechKitErrorType_requestTypeInvalidSpeech", defaultValue:"Speech")
        }
    }
    
    /// An error that is used to capture details of the error event.
    public var error: Error? {
        let err = NSError(domain: "au.com.appdevguy.ossspeechkit",
                          code: rawValue,
                          userInfo: ["message": errorMessage, "request": errorRequestType])
        return err
    }
}

/// The speech recognition task type.
public enum OSSSpeechRecognitionTaskType: Int {
    /// Undefined is the standard recognition type and allows the system to decide which type of task is best.
    case undefined = 0
    /// Use captured speech for text entry purposes.
    ///
    /// Use this when doing a similar task that of the keyboard voice to text function.
    case dictation = 1
    /// Use this short speechs that have specific words or terms.
    case search = 2
    /// Use this for short speechs such as "Yes", "No", "Thanks", etc.
    case confirmation = 3
    
    /// Returns a speech recognition hint based on the enum value.
    public var taskType: SFSpeechRecognitionTaskHint {
        switch self {
        case .undefined:
            return .unspecified
        case .dictation:
            return .dictation
        case .search:
            return .search
        case .confirmation:
            return .confirmation
        }
    }
}

/// Delegate to handle events such as failed authentication for microphone among many more.
public protocol OSSSpeechDelegate: class {
    /// When the microphone has finished accepting audio, this delegate will be called with the final best text output.
    func didFinishListening(withText text: String)
    /// Handle returning authentication status to user - primary use is for non-authorized state.
    func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus)
    /// If the speech recogniser and request fail to set up, this method will be called.
    func didFailToCommenceSpeechRecording()
    /// Method for real time recpetion of translated text.
    func didCompleteTranslation(withText text: String)
    /// Error handling function.
    func didFailToProcessRequest(withError error: Error?)
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
    /// Not all devices support on device speech recognition and only devices operating with iOS 13 or higher support it.
    ///
    /// On device recognition offers many benefits such as working without network connectivity,
    /// no data costs and longer recording-to-transcription.
    ///
    /// On device recognition comes at a cost of accurate transcription though; speech recognition is less accurate with on device recognition.
    public var shouldUseOnDeviceRecognition = false
    
    /// The task type by default is undefined.
    /// Changing the task type will change how speech recognition performs.
    public var recognitionTaskType = OSSSpeechRecognitionTaskType.undefined
    
    /// The object used to enable translation of strings to synthsized voice.
    public var utterance: OSSUtterance?
    
    /// An AVAudioSession that ensure volume controls are correct in various scenarios
    private var session: AVAudioSession?
    
    /// Audio Session can be overriden should you choose to.
    public var audioSession: AVAudioSession {
        get {
            guard let audioSess = session else {
                return AVAudioSession.sharedInstance()
            }
            return audioSess
        }
        set {
            session = newValue
        }
    }
    
    /// This property handles permission authorization.
    /// This property is intentionally named vaguely to prevent accidental overriding.
    public var srp = SFSpeechRecognizer.self
    
    // Voice to text
    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var spokenText: String = ""
    
    // MARK: - Lifecycle
    
    private override init() {
        speechSynthesizer = AVSpeechSynthesizer()
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
        if !utteranceIsValid() {
            guard let speechText = text else {
                debugLog(object: self, message: "Text is empty or nil. Please confirm text has been passed in.")
                delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidUtterance.error)
                return
            }
            // Handle empty text gracefully.
            if speechText.isEmpty {
                debugLog(object: self, message: "Text is empty or nil. Please confirm text has been passed in.")
                delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidUtterance.error)
                return
            }
            utterance = OSSUtterance(string: speechText)
        }
        if let speechText = text, !speechText.isEmpty {
            utterance?.speechString = speechText
        }
        speak()
    }
    
    /// Pass in an attributed string to speak.
    /// This will set the attributed string on the utterance.
    /// - Parameter attributedText: An NSAttributedString object.
    public func speakAttributedText(attributedText: NSAttributedString) {
        // Handle empty text gracefully.
        if attributedText.string.isEmpty {
            debugLog(object: self, message: "Attributed text is empty or nil. Please confirm text has been passed in.")
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidText.error)
            return
        }
        if !utteranceIsValid() {
            // Initialize default utterance
            utterance = OSSUtterance(attributedString: attributedText)
        }
        if utterance!.attributedSpeechString.string != attributedText.string {
            utterance!.attributedSpeechString = attributedText
        }
        speak()
    }
    
    // MARK: - Private Methods

    private func utteranceIsValid() -> Bool {
        guard let _ = utterance else {
            debugLog(object: self, message: "No valid utterance.")
            return false
        }
        return true
    }
    
    private func speak() {
        var speechVoice = OSSVoice()
        if let aVoice = voice {
            speechVoice = aVoice
        }
        let validString = utterance?.speechString ?? "error"
        // Utterance must be an original object in order to be spoken. We redefine an new instance of Utterance each time using the values in the existing utterance.
        let newUtterance = AVSpeechUtterance(string: validString)
        newUtterance.voice = speechVoice
        if let validUtterance = utterance {
            newUtterance.rate = validUtterance.rate
            newUtterance.pitchMultiplier = validUtterance.pitchMultiplier
            newUtterance.volume = validUtterance.volume
        }
        // Ensure volume is correct each time
        setSession(isRecording: false)
        speechSynthesizer.speak(newUtterance)
    }
    
    private func setSession(isRecording: Bool) {
        let category: AVAudioSession.Category = isRecording ? .playAndRecord : .playback
        try? audioSession.setCategory(category, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    // MARK: - Public Voice Recording Methods
    
    /// Record and recognise speech
    ///
    /// This method will check to see if user is authorised to record. If they are, the recording will proceed.
    ///
    /// Upon checking the authorisation and being registered successful, a check to determine if a recording session is active will be made and any active session will be cancelled.
    public func recordVoice(requestMicPermission requested: Bool = true) {
        if requested {
            if audioSession.recordPermission != .granted {
                self.requestMicPermission()
                return
            }
        }
        getMicroPhoneAuthorization()
    }
    
    /// End recording of speech session if one exists.
    public func endVoiceRecording() {
        cancelRecording()
    }
    
    // MARK: - Private Voice Recording
    
    private func requestMicPermission() {
        weak var weakSelf = self
        audioSession.requestRecordPermission { allowed in
            if !allowed {
                weakSelf?.debugLog(object: self, message: "Microphone permission was denied.")
                weakSelf?.delegate?.authorizationToMicrophone(withAuthentication: .denied)
                return
            }
            weakSelf?.getMicroPhoneAuthorization()
        }
    }
    
    private func getMicroPhoneAuthorization() {
        weak var weakSelf = self
        weakSelf?.srp.requestAuthorization { authStatus in
            let status = OSSSpeechKitAuthorizationStatus(rawValue: authStatus.rawValue) ?? .notDetermined
            weakSelf?.delegate?.authorizationToMicrophone(withAuthentication: status)
            if status == .authorized {
                OperationQueue.main.addOperation {
                    weakSelf?.recordAndRecognizeSpeech()
                }
            }
        }
    }
    
    private func cancelRecording() {
        if let voiceRequest = request {
            voiceRequest.endAudio()
            request = nil
        }
        if let engine = audioEngine {
            if engine.isRunning {
                engine.stop()
            }
            let node = engine.inputNode
            node.removeTap(onBus: 0)
            audioEngine = nil
        }
        if let task = recognitionTask {
            task.finish()
        }
    }
    
    func engineSetup(_ engine: AVAudioEngine) {
        let input = engine.inputNode
        let bus = 0
        let inputFormat = input.outputFormat(forBus: 0)
        guard let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 8000, channels: 1, interleaved: true) else {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
            return
        }
        guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
            return
        }
        weak var weakSelf = self
        input.installTap(onBus: bus, bufferSize: 8192, format: inputFormat) { (buffer, time) -> Void in
            var newBufferAvailable = true
            let inputCallback: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                if newBufferAvailable {
                    outStatus.pointee = .haveData
                    newBufferAvailable = false
                    return buffer
                } else {
                    outStatus.pointee = .noDataNow
                    return nil
                }
            }
            let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: AVAudioFrameCount(outputFormat.sampleRate) * buffer.frameLength / AVAudioFrameCount(buffer.format.sampleRate))!
            var error: NSError?
            let status = converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputCallback)
            if status == .error {
                weakSelf?.delegate?.didFailToCommenceSpeechRecording()
                weakSelf?.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
                if let err = error {
                    weakSelf?.debugLog(object: self, message: "Audio Engine conversion error: \(err)")
                }
                return
            }
            weakSelf?.request?.append(convertedBuffer)
        }
        engine.prepare()
        do {
            try engine.start()
            return
        } catch {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
            return
        }
    }
    
    private func recordAndRecognizeSpeech() {
        if let engine = audioEngine {
            if engine.isRunning {
                cancelRecording()
            }
        } else {
            audioEngine = AVAudioEngine()
        }
        setSession(isRecording: true)
        request = SFSpeechAudioBufferRecognitionRequest()
        engineSetup(audioEngine!)
        let identifier = voice?.voiceType.rawValue ?? OSSVoiceEnum.UnitedStatesEnglish.rawValue
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: identifier))
        guard let recogniser = speechRecognizer else {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidSpeechRequest.error)
            return
        }
        if !recogniser.isAvailable {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.recogniserUnavailble.error)
            return
        }
        if let audioRequest = request {
            if #available(iOS 13, *) {
                if recogniser.supportsOnDeviceRecognition {
                    audioRequest.requiresOnDeviceRecognition = shouldUseOnDeviceRecognition
                }
            }
            recogniser.delegate = self
            recogniser.defaultTaskHint = recognitionTaskType.taskType
            recognitionTask = recogniser.recognitionTask(with: audioRequest, delegate: self)
        } else {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidSpeechRequest.error)
        }
    }
}

/// Extension to handle the SFSpeechRecognitionTaskDelegate and SFSpeechRecognizerDelegate methods.
extension OSSSpeech: SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate {
    
    // MARK: - SFSpeechRecognitionTaskDelegate Methods
    
    /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        recognitionTask = nil
        delegate?.didFinishListening(withText: spokenText)
        setSession(isRecording: false)
    }
    
    /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        delegate?.didCompleteTranslation(withText: transcription.formattedString)
    }
    
    /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        spokenText = recognitionResult.bestTranscription.formattedString
    }
    
    public func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {}
    
    public func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {}
    
    // MARK: - SFSpeechRecognizerDelegate Methods
    
    /// Docs available by Google searching for SFSpeechRecognizerDelegate
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {}

}
