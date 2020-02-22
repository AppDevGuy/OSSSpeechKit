//
//  OSSSpeechTests.swift
//  OSSSpeechKit_Tests
//
//  Created by Sean Smith on 8/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import OSSSpeechKit

class OSSSpeechTests: XCTestCase {

    var speechKit: OSSSpeech!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        speechKit = OSSSpeech.shared
        speechKit.utterance = nil
        speechKit.voice = nil
        print("Reset Speech Kit details")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        speechKit = nil
    }

    func testFirstLoadSpeechValues() {
        XCTAssert(speechKit.utterance == nil, "The utterance should be nil.")
        XCTAssert(speechKit.voice == nil, "The voice should be nil.")
    }
    
    func testSpeechStringSetup() {
        speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
        speechKit.speakText("Should Pass")
        speechKit.utterance?.volume = 1.0
        XCTAssert(speechKit.utterance != nil, "The utterance should not be nil.")
        XCTAssert(speechKit.voice != nil, "The voice should not be nil.")
        XCTAssert(speechKit.utterance!.speechString == "Should Pass", "The speechString should equal pass")
    }
    
    func testSpeechAttributStringSetuo() {
        speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
        speechKit.speakAttributedText(attributedText: NSAttributedString(string: "Should Pass"))
        speechKit.utterance?.volume = 1.0
        XCTAssert(speechKit.utterance != nil, "The utterance should not be nil.")
        XCTAssert(speechKit.voice != nil, "The voice should not be nil.")
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
        XCTAssert(speechKit.utterance == nil, "Utterance should be nil")
        speechKit.speakText("Test One")
        speechKit.voice = nil
        XCTAssert(speechKit.voice == nil, "Voice should be nil")
        speechKit.speakText("Test One")
        speechKit.voice = OSSVoice()
        speechKit.speakText("Test Two")
    }
    
    func testSpeechNoAttributedText() {
        speechKit.speakAttributedText(attributedText: NSAttributedString(string: ""))
        speechKit.utterance = nil
        XCTAssert(speechKit.utterance == nil, "Utterance should be nil")
        var attributedText = NSAttributedString(string: "Test One")
        speechKit.speakAttributedText(attributedText: attributedText)
        speechKit.voice = nil
        XCTAssert(speechKit.voice == nil, "Voice should be nil")
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
        // Cannot initialise an utterance without a string
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
        XCTAssert(OSSSpeechAuthorizationStatus.notDetermined.message == "The app's authorization status has not yet been determined.", "Test uncertain authorization message.")
        XCTAssert(OSSSpeechAuthorizationStatus.denied.message == "The user denied your app's request to perform speech recognition.", "Test denied authorization message.")
        XCTAssert(OSSSpeechAuthorizationStatus.restricted.message == "The device prevents your app from performing speech recognition.", "Test restricted authorization message.")
        XCTAssert(OSSSpeechAuthorizationStatus.authorized.message == "The user granted your app's request to perform speech recognition.", "Test authorized message.")
    }
    
    /// This should fail because voice recording is not permitted on simulators.
    func testSpeechRecording() {
        speechKit!.recordVoice()
        speechKit!.delegate = self
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
            self.speechKit!.recordVoice()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                expectation.fulfill()
            })
        })
        self.wait(for: [expectation], timeout: 5.0)
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
    
    func authorizationToMicrophone(withAuthentication type: OSSSpeechAuthorizationStatus) {
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
