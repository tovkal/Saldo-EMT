//
//  UIColor.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 05/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import XCTest
@testable import SaldoEMT

// swiftlint:disable force_cast
class UIColorTest: BaseTest {

    func testInitShouldCreateWhiteColorWhenWhiteHexColor() {
        let hexColor = "FFFFFF"

        do {
            let color = try UIColor(hexColor)
            let coreImageColor = color.coreImageColor
            XCTAssertEqual(255/255, coreImageColor.red)
            XCTAssertEqual(255/255, coreImageColor.green)
            XCTAssertEqual(255/255, coreImageColor.blue)
            XCTAssertEqual(1.0, coreImageColor.alpha)
        } catch {
            XCTFail("Exception should not be thrown")
        }
    }

    func testInitShouldCreateRedishColorWhenRedishHexColorWithNumberSignPrefix() {
        let hexColor = "#DC143C"

        do {
            let color = try UIColor(hexColor)
            let coreImageColor = color.coreImageColor
            XCTAssertEqual(220/255, coreImageColor.red)
            XCTAssertEqual(20/255, coreImageColor.green)
            XCTAssertEqual(60/255, coreImageColor.blue)
            XCTAssertEqual(1.0, coreImageColor.alpha)
        } catch {
            XCTFail("Exception should not be thrown")
        }
    }

    func testInitShouldThrowExceptionWhenInputTooShort() {
        let hexColor = "FFFFF"

        XCTAssertThrowsError(try UIColor(hexColor)) {
            XCTAssertEqual($0 as! UIColorError, UIColorError.inputSizeNotValid)
        }
    }

    func testInitShouldThrowExceptionWhenInputTooLong() {
        let hexColor = "FFFFFFF"

        XCTAssertThrowsError(try UIColor(hexColor)) {
            XCTAssertEqual($0 as! UIColorError, UIColorError.inputSizeNotValid)
        }
    }

    func testInitShouldThrowExceptionWhenHexNotValid() {
        let hexColor = "ZZZZZZ"

        XCTAssertThrowsError(try UIColor(hexColor)) {
            XCTAssertEqual($0 as! UIColorError, UIColorError.unableToScanHexValue)
        }
    }
}
