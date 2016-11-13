//
//  ViewControllerTests.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 11/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import XCTest
import RealmSwift
@testable import SaldoEMT

class MainTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["-isUITest"] = "true"
        app.launch()
    }
    
    func testChangeFare() {
        let app = XCUIApplication()
        XCTAssert(app.staticTexts["Residente"].exists)
        app.buttons["Fares"].tap()
        app.tables.cells.containing(.staticText, identifier:"1.15").staticTexts["No residente"].tap()
        XCTAssert(app.staticTexts["No residente"].exists)
    }
    
    func testAddBalance() {
        let app = XCUIApplication()
        XCTAssert(app.staticTexts["4.0"].exists)
        app.buttons["Balance"].tap()
        let textField = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element
        textField.tap()
        textField.typeText("6")
        app.buttons["Accept"].tap()
        XCTAssert(app.staticTexts["10.0"].exists)
    }
    
    func testCancelBalance() {
        let app = XCUIApplication()
        let fare = app.staticTexts["Residente"]
        XCTAssert(fare.exists)
        app.buttons["Balance"].tap()
        app.buttons["Cancel"].tap()
        XCTAssert(fare.exists)
    }
    
    func testAddTrip() {
        let app = XCUIApplication()
        XCTAssert(app.staticTexts["4"].exists)
        let button = app.buttons["+1 Trip"]
        button.tap()
        XCTAssert(app.staticTexts["3"].exists)
        XCTAssert(app.staticTexts["1"].exists)
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        XCTAssert(app.otherElements["SVProgressHUD"].exists)
    }
}
