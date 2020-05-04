//
//  OSSSpeechKitUITests.swift
//  OSSSpeechKit_Tests
//
//  Created by Sean Smith on 4/5/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class OSSSpeechKitUITests: XCTestCase {

    private var app: XCUIApplication!
    private let languageTableViewName = "OSSSpeechKitLanguageTableView"
    private let languageTableViewCellSuffix = "OSSLanguageCell"
    private let micButtonIdentifier = "OSSSpeechKitMicButton"
    
    override func setUp() {
        continueAfterFailure = false
        if app == nil {
            app = XCUIApplication()
        }
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
    
    func testExample() throws {
        if app == nil {
            app = XCUIApplication()
        }
        app.launch()
    }
    
    // MARK: - Helper Methods
    
    func testForCellExistence() {
        let detailstable = app.tables.matching(identifier: languageTableViewName)
        let firstCell = detailstable.cells.element(matching: .cell, identifier: "\(languageTableViewCellSuffix)_0_0")
        let existencePredicate = NSPredicate(format: "exists == 1")
        let expectationEval = expectation(for: existencePredicate, evaluatedWith: firstCell, handler: nil)
        let mobWaiter = XCTWaiter.wait(for: [expectationEval], timeout: 10.0)
        XCTAssert(XCTWaiter.Result.completed == mobWaiter, "Test Case Failed.")
    }

    func testForCellSelection() {
        let detailstable = app.tables.matching(identifier: languageTableViewName)
        let firstCell = detailstable.cells.element(matching: .cell, identifier: "\(languageTableViewCellSuffix)_0_0")
        let predicate = NSPredicate(format: "isHittable == true")
        let expectationEval = expectation(for: predicate, evaluatedWith: firstCell, handler: nil)
        let waiter = XCTWaiter.wait(for: [expectationEval], timeout: 10.0)
        XCTAssert(XCTWaiter.Result.completed == waiter, "Test Case Failed.")
        firstCell.tap()
        // Enable playing of audio
        sleep(5)
    }
    
    func testButtonRecordsAndCancels() {
//        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.matching(identifier: micButtonIdentifier).element.tap()
        sleep(3)
//        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.matching(identifier: micButtonIdentifier).element.tap()
        sleep(2)
    }

}
