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
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        speechKit = nil
    }

    func testFirstLoadSpeechValues() {
        XCTAssert(speechKit.utterance == nil, "The utterance should be nil.")
        XCTAssert(speechKit.voice == nil, "The voice should be nil.")
    }
    
    func testSpeechSetup() {
        speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
        speechKit.utterance?.volume = 1.0
        speechKit.speakText(text: "Should Pass")
        speechKit.speakAttributedText(attributedText: NSAttributedString(string: "Should Pass"))
        XCTAssert(speechKit.utterance != nil, "The utterance should not be nil.")
        XCTAssert(speechKit.voice != nil, "The voice should not be nil.")
        XCTAssert(speechKit.utterance!.speechString == "Should Pass", "The speechString should equal pass")
        XCTAssert(speechKit.utterance!.attributedSpeechString.string == "Should Pass", "The attributedSpeechString should equal pass")
    }
    
    func testRegularSetup() {
        speechKit.voice = OSSVoice()
        speechKit.speakText(text: "Should Pass")
        XCTAssert(speechKit.voice != nil, "The voice should not be nil.")
        XCTAssert(speechKit.utterance!.speechString == "Should Pass", "The speechString should equal pass")
        XCTAssert(speechKit.voice?.language == OSSVoiceEnum.UnitedStatesEnglish.rawValue, "Voice language should be United States English")
    }

}
