//
//  Double.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 05/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import XCTest
@testable import SaldoEMT

class DoubleTests: BaseTest {

    func testDoubleToStringShouldReturnStringWithoutDecimalsWhenInputZero() {
        let double = 0.0

        XCTAssertEqual("0", double.toDecimalString())
    }

    func testDoubleToStringShouldReturnStringWithOneDecimalPlaceWhenInputWithDecimalPlace() {
        let double = 0.1

        XCTAssertEqual("0.1", double.toDecimalString())
    }

    func testDoubleToStringShouldReturnStringWithTwoDecimalPlaceWhenInputWithTwoDecimalPlaces() {
        let double = 0.12

        XCTAssertEqual("0.12", double.toDecimalString())
    }
}
