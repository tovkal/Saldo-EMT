//
//  ViewControllerTests.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 11/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import XCTest
@testable import SaldoEMT

class CoreTests: UITestCase {

    func testChangeFare() {
        waitForElementToAppear(app.staticTexts["Resident"])
        app.buttons["Fares"].tap()
        app.tables.cells.containing(.staticText, identifier: "1.15").staticTexts["Non-resident"].tap()
        waitForElementToAppear(app.staticTexts["Non-resident"])
    }

    func testAddBalance() {
        waitForElementToAppear(app.staticTexts["4.0"])
        app.buttons["Balance"].tap()
        let textField = app.textFields.firstMatch
        textField.tap()
        textField.typeText("6")
        app.buttons["Accept"].tap()
        waitForElementToAppear(app.staticTexts["10.0"])
    }

    func testCancelBalance() {
        let fare = app.staticTexts["Resident"]
        waitForElementToAppear(fare)
        app.buttons["Balance"].tap()
        app.buttons["Cancel"].tap()
        waitForElementToAppear(fare)
    }

    func testAddTrip() {
        waitForElementToAppear(app.staticTexts["5"])
        let button = app.buttons["+1 Trip"]
        button.tap()
        waitForElementToAppear(app.staticTexts["4"])
        waitForElementToAppear(app.staticTexts["1"])
        button.tap(withNumberOfTaps: 5, numberOfTouches: 5)
        waitForElementToAppear(app.otherElements["SVProgressHUD"])
    }
}
