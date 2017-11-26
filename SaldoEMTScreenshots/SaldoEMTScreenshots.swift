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
        app.buttons["Fares"].tap()
        snapshot("02FaresScreen")
        app.navigationBars["SaldoEMT.FaresView"].buttons["Cancel"].tap()
        app.buttons["Balance"].tap()
        snapshot("03BalanceScreen")
    }
}
