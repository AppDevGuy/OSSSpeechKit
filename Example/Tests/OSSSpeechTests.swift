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
        speechKit.speakText(text: "Should Pass")
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
        speechKit.speakText(text: "Should Pass")
        XCTAssert(speechKit.voice != nil, "The voice should not be nil.")
        XCTAssert(speechKit.utterance!.speechString == "Should Pass", "The speechString should equal pass")
        XCTAssert(speechKit.voice?.language == OSSVoiceEnum.UnitedStatesEnglish.rawValue, "Voice language should be United States English")
    }
    
    func testSpeechNoText() {
        speechKit.speakText(text: "")
        speechKit.utterance = nil
        XCTAssert(speechKit.utterance == nil, "Utterance should be nil")
        speechKit.speakText(text: "Test One")
        speechKit.voice = nil
        XCTAssert(speechKit.voice == nil, "Voice should be nil")
        speechKit.speakText(text: "Test One")
        speechKit.voice = OSSVoice()
        speechKit.speakText(text: "Test Two")
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

}
