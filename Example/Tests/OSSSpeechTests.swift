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
import XCTest
@testable import OSSSpeechKit
import AVKit

class OSSSpeechTests: XCTestCase {

    var speechKit: OSSSpeech!
    
    override func setUp() {
        speechKit = OSSSpeech.shared
        speechKit.utterance = nil
        speechKit.voice = nil
        speechKit.srp = SFSpeechRecognizerMock.self
        print("Reset Speech Kit details")
    }

    override func tearDown() {
        speechKit = nil
    }
    
    func testCanInitWithCustomSynth() {
        let synth = AVSpeechSynthesizer()
        let speechKit = OSSSpeech(speechSynthesizer: synth)
        XCTAssertNotNil(speechKit)
    }
    
    func testAudioSessionValid() {
        let exp = expectation(description: "Speech Recogniser Permission")
        var speechAuth = false
        SFSpeechRecognizerMock.requestAuthorization { authStatus in
            speechAuth = authStatus == .authorized
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
        XCTAssert(speechAuth == true)
    }

    /// This test exists purely for code coverage. 
    func testVoiceDecoderNil() {
        // Ignore the deprecation warning as the alternative solution returns nil, which is not what we want - we want a valid value.
        // The below option is the non-deprectaed option however it returns nil, which we don't want.
        // let archiver = NSKeyedUnarchiver(forReadingFrom: Data())
        let archiver = NSKeyedUnarchiver(forReadingWith: Data())
        let voice = OSSVoice(coder: archiver)
        let utterance = OSSUtterance(coder: archiver)
        XCTAssertNil(voice)
        XCTAssertNil(utterance)
    }
    
    func testUtteranceInit() {
        let utterance = OSSUtterance()
        XCTAssert(utterance.speechString == "ERROR")
        XCTAssert(utterance.attributedSpeechString.string == "ERROR")
    }
    
    func testFirstLoadSpeechValues() {
        XCTAssert(speechKit.utterance == nil, "The utterance should be nil.")
        XCTAssert(speechKit.voice == nil, "The voice should be nil.")
    }
    
    func testSpeakWithNoSetup() {
        speechKit.speakText(nil)
        XCTAssertNil(speechKit.voice)
        XCTAssertNil(speechKit.utterance)
    }
    
    func testSpeechStringSetupInvalid() {
        speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
        speechKit.speakText(nil)
        speechKit.recognitionTaskType = .confirmation
        XCTAssertNil(speechKit.utterance, "The utterance should be nil.")
        XCTAssertNotNil(speechKit.voice, "The voice should not be nil.")
        XCTAssert(speechKit.recognitionTaskType == .confirmation)
        speechKit.recognitionTaskType = .dictation
        XCTAssert(speechKit.recognitionTaskType == .dictation)
        speechKit.recognitionTaskType = .search
        XCTAssert(speechKit.recognitionTaskType == .search)
        speechKit.recognitionTaskType = .undefined
        XCTAssert(speechKit.recognitionTaskType == .undefined)
    }
    
    func testSpeechStringSetup() {
        speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
        speechKit.speakText("Should Pass")
        speechKit.utterance?.volume = 1.0
        XCTAssertNotNil(speechKit.utterance, "The utterance should not be nil.")
        XCTAssertNotNil(speechKit.voice, "The voice should not be nil.")
        XCTAssert(speechKit.utterance!.speechString == "Should Pass", "The speechString should equal pass")
    }
    
    func testSpeechAttributedStringSetup() {
        speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
        speechKit.speakAttributedText(attributedText: NSAttributedString(string: "Should Pass"))
        speechKit.utterance?.volume = 1.0
        XCTAssertNotNil(speechKit.utterance, "The utterance should not be nil.")
        XCTAssertNotNil(speechKit.voice, "The voice should not be nil.")
        XCTAssert(speechKit.utterance!.attributedSpeechString.string == "Should Pass", "The attributedSpeechString should equal pass")
    }
    
    func testRegularSetup() {
        speechKit.voice = OSSVoice()
        speechKit.speakText("Should Pass")
        XCTAssert(speechKit.voice != nil, "The voice should not be nil.")
        XCTAssert(speechKit.utterance!.speechString == "Should Pass", "The speechString should equal pass")
        XCTAssert(speechKit.voice?.language == OSSVoiceEnum.UnitedStatesEnglish.rawValue, "Voice language should be United States English")
    }
    
    func testSpeechNoText() {
        speechKit.speakText("")
        speechKit.utterance = nil
        XCTAssertNil(speechKit.utterance, "Utterance should be nil")
        speechKit.speakText("Test One")
        speechKit.voice = nil
        XCTAssertNil(speechKit.voice, "Voice should be nil")
        speechKit.speakText("Test One")
        speechKit.voice = OSSVoice()
        speechKit.speakText("Test Two")
    }
    
    func testSpeechNoAttributedText() {
        speechKit.speakAttributedText(attributedText: NSAttributedString(string: ""))
        speechKit.utterance = nil
        XCTAssertNil(speechKit.utterance, "Utterance should be nil")
        var attributedText = NSAttributedString(string: "Test One")
        speechKit.speakAttributedText(attributedText: attributedText)
        speechKit.voice = nil
        XCTAssertNil(speechKit.voice, "Voice should be nil")
        speechKit.speakAttributedText(attributedText: attributedText)
        attributedText = NSAttributedString(string: "Test Two")
        speechKit.voice = OSSVoice()
        speechKit.speakAttributedText(attributedText: attributedText)
    }
    
    func testOSSSpeechEnum() {
        for language in OSSVoiceEnum.allCases {
            XCTAssert(language.demoMessage == language.demoMessage, "Message has to be the same")
            XCTAssert(language.title == language.title, "Title has to be the same")
            let firstDetails = language.getDetails()
            let secondDetails = language.getDetails()
            XCTAssert(firstDetails.name == secondDetails.name, "Details has to be the same")
        }
    }
    
    func testChangesToUtterance() {
        let newVoice = OSSVoice()
        newVoice.language = OSSVoiceEnum.Indonesian.rawValue
        newVoice.quality = .enhanced
        speechKit.voice = newVoice
        // Cannot initialize an utterance without a string
        let utterance = OSSUtterance(string: "Testing")
        utterance.volume = 0.5
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.2
        speechKit.utterance = utterance
        speechKit.speakText(utterance.speechString)
        XCTAssert(speechKit.utterance!.rate == 0.5, "Rate should equal 0.5")
        XCTAssert(speechKit.utterance!.volume == 0.5, "Volume should equal 0.5")
        XCTAssert(speechKit.utterance!.pitchMultiplier == 1.2, "Pitch should equal 1.2")
        XCTAssert(speechKit.voice!.quality == .enhanced, "Quality should equal enhanced")
        XCTAssert(speechKit.voice!.voiceType == .Indonesian, "Default voice type should equal Indonesian")
        XCTAssert(speechKit.voice!.language == OSSVoiceEnum.Indonesian.rawValue, "Language should equal Indonesian")
    }
    
    func testAuthEnumValues() {
        var status = OSSSpeechKitAuthorizationStatus.notDetermined
        XCTAssert(status.rawValue == 0)
        XCTAssert(status.message == "The app's authorization status has not yet been determined.", "Test uncertain authorization message.")
        status = OSSSpeechKitAuthorizationStatus.denied
        XCTAssert(status.rawValue == 1)
        XCTAssert(status.message == "The user denied your app's request to perform speech recognition.", "Test denied authorization message.")
        status = OSSSpeechKitAuthorizationStatus.restricted
        XCTAssert(status.rawValue == 2)
        XCTAssert(status.message == "The device prevents your app from performing speech recognition.", "Test restricted authorization message.")
        status = OSSSpeechKitAuthorizationStatus.authorized
        XCTAssert(status.rawValue == 3)
        XCTAssert(status.message == "The user granted your app's request to perform speech recognition.", "Test authorized message.")
    }
    
    func testErrorEnumValues() {
        var errorType = OSSSpeechKitErrorType.noMicrophoneAccess
        XCTAssert(errorType.rawValue == -1)
        XCTAssert(errorType.errorMessage == "Access to the microphone is unavailable.")
        XCTAssert(errorType.errorRequestType == "Recording")
        errorType = OSSSpeechKitErrorType.invalidUtterance
        XCTAssert(errorType.rawValue == -2)
        XCTAssert(errorType.errorMessage == "The utterance is invalid. Please ensure you have created one or passed in valid text to speak.")
        XCTAssert(errorType.errorRequestType == "Speech or Recording")
        errorType = OSSSpeechKitErrorType.invalidText
        XCTAssert(errorType.rawValue == -3)
        XCTAssert(errorType.errorMessage == "The text provided to the utterance is either empty or has not been set.")
        XCTAssert(errorType.errorRequestType == "Speech")
        errorType = OSSSpeechKitErrorType.invalidVoice
        XCTAssert(errorType.rawValue == -4)
        XCTAssert(errorType.errorMessage == "In order to speak text, a valid voice is required.")
        XCTAssert(errorType.errorRequestType == "Speech")
        errorType = OSSSpeechKitErrorType.invalidSpeechRequest
        XCTAssert(errorType.rawValue == -5)
        XCTAssert(errorType.errorMessage == "The speech request is invalid. Please ensure the string provided contains text.")
        XCTAssert(errorType.errorRequestType == "Speech")
        errorType = OSSSpeechKitErrorType.invalidAudioEngine
        XCTAssert(errorType.rawValue == -6)
        XCTAssert(errorType.errorMessage == "The audio engine is unavailable. Please try again soon.")
        XCTAssert(errorType.errorRequestType == "Recording")
        errorType = OSSSpeechKitErrorType.recogniserUnavailble
        XCTAssert(errorType.rawValue == -7)
        XCTAssert(errorType.errorMessage == "The Speech Recognition service is currently unavailable.")
        XCTAssert(errorType.errorRequestType == "Speech")
        guard let error = OSSSpeechKitErrorType.noMicrophoneAccess.error as NSError? else {
            XCTAssert(true == false, "Error must not be nil.")
            return
        }
        let message = error.userInfo["message"] as? String
        let requestType = error.userInfo["request"] as? String
        XCTAssert(error.code == -1)
        XCTAssertNotNil(message)
        XCTAssertNotNil(requestType)
        if let aMessage = message, let rqType = requestType {
            XCTAssert(aMessage == "Access to the microphone is unavailable.")
            XCTAssert(rqType == "Recording")
        }
    }
    
    func testRecognitionTaskTypeEnum() {
        XCTAssert(OSSSpeechRecognitionTaskType.undefined.rawValue == 0)
        XCTAssert(OSSSpeechRecognitionTaskType.undefined.taskType.rawValue == 0)
        XCTAssert(OSSSpeechRecognitionTaskType.dictation.rawValue == 1)
        XCTAssert(OSSSpeechRecognitionTaskType.dictation.taskType.rawValue == 1)
        XCTAssert(OSSSpeechRecognitionTaskType.search.rawValue == 2)
        XCTAssert(OSSSpeechRecognitionTaskType.search.taskType.rawValue == 2)
        XCTAssert(OSSSpeechRecognitionTaskType.confirmation.rawValue == 3)
        XCTAssert(OSSSpeechRecognitionTaskType.confirmation.taskType.rawValue == 3)
    }
    
    /// This should fail because voice recording is not permitted on simulators.
    func testSpeechRecording() {
        speechKit?.recordVoice(requestMicPermission: false)
        speechKit?.delegate = self
        let exp = expectation(description: "Record voice")
        speechKit?.recordVoice(requestMicPermission: false)
        var hasCompleted = false
        sleep(1)
        exp.fulfill()
        speechKit?.endVoiceRecording()
        hasCompleted = true
        sleep(1)
        waitForExpectations(timeout: 3)
        XCTAssert(hasCompleted, "Did not complete the Speech Recording expectation")
    }

	#if !os(macOS)
    // TODO: Need to write a mock for authorizing speech and the recording functions.
    // Cannot interact with UI to approve the use of Microphone which results in a crash when trying to call record functions.
//    func testRecordPermission() {
//        speechKit?.recordVoice(requestMicPermission: true)
//        let recPermission = AVAudioSession.sharedInstance().recordPermission
//        sleep(2)
//        XCTAssertEqual(recPermission, .granted)
//    }
    
    func testAudioSessionSetting() {
        XCTAssertNotNil(speechKit?.audioSession)
        let customSession = AVAudioSession()
        speechKit?.audioSession = customSession
        try? customSession.setCategory(.ambient)
        XCTAssert(customSession.category == .ambient)
    }
	#endif
    
    func testUtilityClassStrings() {
        let util = OSSSpeechUtility()
        var mainBundleStringNotSDKString = util.getString(forLocalizedName: "OSSSpeechKitTests_testString", defaultValue: "")
        XCTAssert(mainBundleStringNotSDKString.isEmpty, "Localized string does not exist in the SDK; the default value (\"\") should be returned.")
        util.stringsTableName = "LocalizableTests"
        guard Bundle.main.path(forResource: util.stringsTableName, ofType: "strings") != nil else {
            XCTFail("Strings file does not exist")
            return
        }
        // Assert that we have overriden the table name.
        XCTAssertEqual(util.stringsTableName, "LocalizableTests", "The table name did not override the default value.")

        // Check that we are retrieveing the correct string.
        mainBundleStringNotSDKString = util.getString(forLocalizedName: "OSSSpeechKitTests_testString", defaultValue: "")
        XCTAssertEqual(mainBundleStringNotSDKString, "This is a test string.", "The name of the localized string should now be found.")

        // Check that we are retrieveing the correct string for key.
        let testString = util.getString(forLocalizedName: "OSSSpeechKitAuthorizationStatus_messageNotDetermined", defaultValue: "")
        let expectedString = "The test class is overriding the message: The app's authorization status has not yet been determined."
        XCTAssertEqual(testString, expectedString)

        // Check that we return the correct error string.
        let blankKey = util.getString(forLocalizedName: "", defaultValue: "")
        XCTAssert(blankKey == "!&!&!&!&!&!&!&!&!&!&!&!&!&!&!", "Passing in an empty string should return an obvious error string.")
    }

}

extension OSSSpeechTests: OSSSpeechDelegate {
    func didCompleteTranslation(withText text: String) {
        print("Translation completed with text: \(text)")
    }
    
    func didFailToProcessRequest(withError error: Error?) {
        guard let err = error else {
            print("Failed to process the request")
            return
        }
        print("Failed to process the request \(err)")
    }
    
    func didFinishListening(withText text: String) {
        guard let speech = speechKit else {
            return
        }
        speech.debugLog(object: self, message: "Finished listening to text with text \(text)")
    }
    
    func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus) {
        guard let speech = speechKit else {
            return
        }
        speech.debugLog(object: self, message: "Authorization state: \(type.message)")
    }
    
    func didFailToCommenceSpeechRecording() {
        guard let speech = speechKit else {
            return
        }
        speech.debugLog(object: self, message: "Did fail to commence speech.")
    }
}
#endif
