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

#if canImport(Speech)
import Speech
import Foundation
import AVFoundation

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
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitAuthorizationStatus_messageNotDetermined", defaultValue: "The app's authorization status has not yet been determined.")
        case .denied:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitAuthorizationStatus_messageDenied", defaultValue: "The user denied your app's request to perform speech recognition.")
        case .restricted:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitAuthorizationStatus_messageRestricted", defaultValue: "The device prevents your app from performing speech recognition.")
        case .authorized:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitAuthorizationStatus_messageAuthorized", defaultValue: "The user granted your app's request to perform speech recognition.")
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
    /// Voice record is invalid
    case invalidRecordVoice = -8
    ///  Voice record file path is Invalid
    case invalidVoiceFilePath = -9
    /// Voice record file path can not delete
    case invalidDeleteVoiceFilePath = -10
    /// Voice record file path can not transcription
    case invalidTranscriptionFilePath = -11

    /// The OSSSpeechKit error message string.
    ///
    /// The error message strings can be altered in the Localized strings file.
    public var errorMessage: String {
        switch self {
        case .noMicrophoneAccess:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageNoMicAccess", defaultValue: "Access to the microphone is unavailable.")
        case .invalidUtterance:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageInvalidUtterance", defaultValue: "The utterance is invalid. Please ensure you have created one or passed in valid text to speak.")
        case .invalidText:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageInvalidText", defaultValue: "The text provided to the utterance is either empty or has not been set.")
        case .invalidVoice:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageInvalidVoice", defaultValue: "In order to speak text, a valid voice is required.")
        case .invalidSpeechRequest:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageInvalidSpeechRequest", defaultValue: "The speech request is invalid. Please ensure the string provided contains text.")
        case .invalidAudioEngine:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageInvalidAudioEngine", defaultValue: "The audio engine is unavailable. Please try again soon.")
        case .recogniserUnavailble:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageRecogniserUnavailable", defaultValue: "The Speech Recognition service is currently unavailable.")
        case .invalidRecordVoice:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageInvalidRecordVoice", defaultValue: "The user voice recoeder service is not working.")
        case .invalidVoiceFilePath:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageInvalidVoiceFolePath", defaultValue: "The user voice file path can not create.")
        case .invalidDeleteVoiceFilePath:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageInvalidDeleteVoiceFilePath", defaultValue: "The user voice file path can not delete.")
        case .invalidTranscriptionFilePath:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_messageInvalidTranscriptionFilePath", defaultValue: "Voice record file path can not transcription.")
        }
    }

    /// The highlevel type of error that occured.
    ///
    /// A String will be used in the OSSSpeechKitErrorType error: Error? that is returned when an exception is thrown.
    public var errorRequestType: String {
        switch self {
        case .noMicrophoneAccess,
            .invalidAudioEngine,
            .invalidRecordVoice:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_requestTypeNoMicAccess", defaultValue: "Recording")
        case .invalidUtterance:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_requestTypeInvalidUtterance", defaultValue: "Speech or Recording")
        case .invalidText,
             .invalidVoice,
             .invalidSpeechRequest,
             .recogniserUnavailble:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_requestTypeInvalidSpeech", defaultValue: "Speech")
        case .invalidVoiceFilePath,.invalidDeleteVoiceFilePath:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_requestTypeInvalidFilePath", defaultValue: "File")
        case .invalidTranscriptionFilePath:
            return OSSSpeechUtility().getString(forLocalizedName: "OSSSpeechKitErrorType_requestTypeInvalidTranscriptionFilePath", defaultValue: "Transcription")
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
public protocol OSSSpeechDelegate: AnyObject {
    /// When the microphone has finished accepting audio, this delegate will be called with the final best text output.
    func didFinishListening(withText text: String)
    ///When the microphone has finished accepting recording, this function will be called with the final best text output or voice file path.
    func didFinishListening(withAudioFileURL url: URL,withText text: String)
    /// Handle returning authentication status to user - primary use is for non-authorized state.
    func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus)
    /// If the speech recogniser and request fail to set up, this method will be called.
    func didFailToCommenceSpeechRecording()
    /// Method for real time recpetion of translated text.
    func didCompleteTranslation(withText text: String)
    /// Error handling function.
    func didFailToProcessRequest(withError error: Error?)
    /// When delete some voice file,this delegate will be return success or not
    func deleteVoiceFile(withFinish finish: Bool ,withError error: Error?)
    /// Get the content according to the path of the voice file
    func voiceFilePathTranscription(withText text:String)
}


/// Speech is the primary interface. To use, set the voice and then call `.speak(string: "your string")`
public class OSSSpeech: NSObject {

    // MARK: - Private Properties

    /// A user voice recoder
    private var audioRecorder: AVAudioRecorder?
    /// When we record the user voice and success,so return audio URL options.
    private var audioFileURL: URL!
    /// User can save audio record or not defult true
    public var saveRecord:Bool = true
    
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

    #if !os(macOS)
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
    #endif

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

    /// Pause speaking text
    ///
    /// Will check if the current speech synthesizer session is speaking before attempting to pause.
    public func pauseSpeaking() {
        if !speechSynthesizer.isSpeaking { return }
        speechSynthesizer.pauseSpeaking(at: .immediate)
    }

    /// Continue speaking text
    ///
    /// Will check if the current speech synthesizer session is paused before attempting to continue speaking.
    public func continueSpeaking() {
        if !speechSynthesizer.isPaused { return }
        speechSynthesizer.continueSpeaking()
    }

    /// Force the ending of speaking.
    ///
    /// Does not remove or reset the utterance or voice - only stops the current speaking if it's active.
    /// Also checks to see if the current synthesizer session is paused.
    public func stopSpeaking() {
        guard speechSynthesizer.isSpeaking || speechSynthesizer.isPaused else {
             return
        }
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    // MARK: - Private Methods

    private func utteranceIsValid() -> Bool {
        guard utterance != nil else {
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
        stopSpeaking()
        speechSynthesizer.speak(newUtterance)
    }

    @discardableResult private func setSession(isRecording: Bool) -> Bool {
        #if !os(macOS)
        do {
            let category: AVAudioSession.Category = isRecording ? .playAndRecord : .playback
            try audioSession.setCategory(category, options: isRecording ? .defaultToSpeaker : .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            isRecording ? try audioSession.setActive(true) : try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            return true
        } catch {
            if isRecording {
                delegate?.didFailToCommenceSpeechRecording()
            }
            delegate?.didFailToProcessRequest(withError: error)
            return false
        }
        #else
        return false
        #endif
    }

    // MARK: - Public Voice Recording Methods

    /// Record and recognise speech
    ///
    /// This method will check to see if user is authorised to record. If they are, the recording will proceed.
    ///
    /// Upon checking the authorisation and being registered successful, a check to determine if a recording session is active will be made and any active session will be cancelled.
    public func recordVoice(requestMicPermission requested: Bool = true) {
        #if !os(macOS)
        if requested {
            if audioSession.recordPermission != .granted {
                self.requestMicPermission()
                return
            }
        }
        #endif
        getMicroPhoneAuthorization()
    }

    /// End recording of speech session if one exists.
    public func endVoiceRecording() {
        cancelRecording()
    }

    // MARK: - Private Voice Recording

    private func requestMicPermission() {
        #if !os(macOS)
        audioSession.requestRecordPermission {[weak self] allowed in
            guard let self = self else { return }
            if !allowed {
                self.debugLog(object: self, message: "Microphone permission was denied.")
                self.delegate?.authorizationToMicrophone(withAuthentication: .denied)
                return
            }
            self.getMicroPhoneAuthorization()
        }
        #endif
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

    private func resetAudioEngine() {
        guard let engine = audioEngine else {
            audioEngine = AVAudioEngine()
            return
        }
        if engine.isRunning {
            engine.stop()
        }
        let node = engine.inputNode
        node.removeTap(onBus: 0)
        
        audioRecorder?.stop()
        
        if node.inputFormat(forBus: 0).channelCount == 0 {
            node.reset()
        }
        // Clean slate the audio engine.
        audioEngine?.reset()
    }

    private func cancelRecording() {
        if let voiceRequest = request {
            voiceRequest.endAudio()
            request = nil
        }
        if let task = recognitionTask {
            task.finish()
        }
        resetAudioEngine()
    }

    func engineSetup() {
        if audioEngine == nil {
            audioEngine = AVAudioEngine()
        }
        guard let audioEngine else {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
            return
        }
        let input = audioEngine.inputNode
        let bus = 0
        let recordingFormat = input.outputFormat(forBus: 0)
        guard let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 8000, channels: 1, interleaved: true) else {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
            return
        }
        guard let converter = AVAudioConverter(from: recordingFormat, to: outputFormat) else {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
            return
        }
        input.installTap(onBus: bus, bufferSize: 8192, format: recordingFormat) { [weak self] (buffer, _) -> Void in
            var newBufferAvailable = true
            let inputCallback: AVAudioConverterInputBlock = { _, outStatus in
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
                self?.delegate?.didFailToCommenceSpeechRecording()
                self?.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
                if let err = error {
                    self?.debugLog(object: self as Any, message: "Audio Engine conversion error: \(err)")
                }
                return
            }
            self?.request?.append(convertedBuffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidAudioEngine.error)
        }
    }

    private func recordAndRecognizeSpeech() {
        if let speechRecognizer, !speechRecognizer.isAvailable {
            cancelRecording()
            setSession(isRecording: false)
        }
        if speechSynthesizer.isSpeaking {
            stopSpeaking()
        }
        // If the audio session is not configured, we must not continue.
        // The audio engine will force an uncatchable crash.
        // This seemse to ONLY be true in simulator so CI tests often randomly fail.
        guard setSession(isRecording: true) else {
            return
        }
        request = SFSpeechAudioBufferRecognitionRequest()
        engineSetup()
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
            if recogniser.supportsOnDeviceRecognition {
                audioRequest.requiresOnDeviceRecognition = shouldUseOnDeviceRecognition
            }
            recogniser.delegate = self
            recogniser.defaultTaskHint = recognitionTaskType.taskType
            recognitionTask = recogniser.recognitionTask(with: audioRequest, delegate: self)
        } else {
            delegate?.didFailToCommenceSpeechRecording()
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidSpeechRequest.error)
        }
        
        if self.saveRecord {
            readyToRecord()
        }
    }
    
    /// When we use the speech function then record the user voice
    private func readyToRecord()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
                    
        audioFileURL = getDocumentsDirectory().appendingPathComponent("\(dateString)-osKit.m4a")

        let audioSettings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                           AVSampleRateKey: 12000,
                     AVNumberOfChannelsKey: 1,
                  AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: self.audioFileURL!, settings: audioSettings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidRecordVoice.error)
        }
    }

    /// Get documents directory
    public func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
        
    /// Delete one voice file(s)
    public func deleteVoiceFolderItem(url:URL?) {
        
        let fileManager = FileManager.default
        let folderURL = getDocumentsDirectory()
        do {
            let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil,options: .skipsHiddenFiles)
            for fileURL in contents {
                guard let pathUrl = url else {
                    if fileURL.absoluteString.contains("-osKit.m4a") {
                        try fileManager.removeItem(at: fileURL)
                    }
                    return
                }
                if fileURL.absoluteString == pathUrl.absoluteString {
                    try fileManager.removeItem(at: fileURL)
                    delegate?.deleteVoiceFile(withFinish: true, withError: nil)
                }
            }
            guard url != nil else {
                delegate?.deleteVoiceFile(withFinish: true, withError: nil)
                return
            }
        } catch {
            delegate?.deleteVoiceFile(withFinish: false, withError: OSSSpeechKitErrorType.invalidDeleteVoiceFilePath.error)
        }
    }
    
    /// Transcription voice file path
    public func recognizeSpeech(filePath: URL,finalBlock:((_ text:String)->Void)? = nil) {
        let identifier = voice?.voiceType.rawValue ?? OSSVoiceEnum.UnitedStatesEnglish.rawValue
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: identifier))
        guard let audioFile = try? AVAudioFile(forReading: filePath) else {
            return
        }
        let request = SFSpeechURLRecognitionRequest(url: audioFile.url)
        speechRecognizer!.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                if result.isFinal {
                    let transcription = result.bestTranscription.formattedString
                    if finalBlock != nil {
                        finalBlock!(transcription)
                    }
                    else {
                        self.delegate?.voiceFilePathTranscription(withText: transcription)
                    }
                }
            } else if error != nil {
                self.delegate?.didFailToProcessRequest(withError: OSSSpeechKitErrorType.invalidTranscriptionFilePath.error)
            }
        })
    }
}

/// Extension to handle the SFSpeechRecognitionTaskDelegate and SFSpeechRecognizerDelegate methods.
extension OSSSpeech: SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate {

    // MARK: - SFSpeechRecognitionTaskDelegate Methods

    /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        recognitionTask = nil
        delegate?.didFinishListening(withText: spokenText)
        if saveRecord{
            delegate?.didFinishListening(withAudioFileURL: audioFileURL!, withText: spokenText)
        }
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

// MARK: AVAudioRecorderDelegate
extension OSSSpeech: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            audioRecorder?.stop()
        }
    }
}
#endif
