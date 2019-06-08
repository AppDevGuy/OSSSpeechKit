import XCTest
import OSSSpeechKit

class Tests: XCTestCase {
    
    var speechKit: OSSSpeech!
    
    override func setUp() {
        super.setUp()
        speechKit = OSSSpeech.shared
        speechKit.voice = OSSVoice(quality: .enhanced, language: .Australian)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(speechKit != nil, "speechKit instance cannot be nil")
        XCTAssert(speechKit.voice != nil, "Voice instance cannot be nil")
        XCTAssert(speechKit.voice?.language == OSSVoiceEnum.Australian.rawValue, "Voice language should be Australian")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
