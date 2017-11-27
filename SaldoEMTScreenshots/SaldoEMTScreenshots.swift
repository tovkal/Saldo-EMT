//
//  SaldoEMTScreenshots.swift
//  SaldoEMTScreenshots
//
//  Created by Andrés Pizá Bückmann on 26/11/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import XCTest

class SaldoEMTScreenshots: XCTestCase {

    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testSnapshots() {
        snapshot("01HomeScreen")
        let app = XCUIApplication()
        app.buttons[localizedString(key: "home.button-bar.fares")].tap()
        snapshot("02FaresScreen")
        app.buttons[localizedString(key: "buttons.cancel")].tap()
        app.buttons[localizedString(key: "home.button-bar.balance")].tap()
        snapshot("03BalanceScreen")
    }

    func localizedString(key: String) -> String {
        let localizationBundle = Bundle(path: Bundle(for: SaldoEMTScreenshots.self).path(forResource: deviceLanguage, ofType: "lproj")!)
        let result = NSLocalizedString(key, bundle:localizationBundle!, comment: "")
        return result
    }

}
