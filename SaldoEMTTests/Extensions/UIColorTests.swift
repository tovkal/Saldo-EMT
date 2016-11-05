//
//  UIColor.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 05/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import XCTest
@testable import SaldoEMT

class UIColorTest: XCTestCase {
 
    func testInitShouldCreateWhiteColorWhenWhiteHexColor() {
        let hexColor = "FFFFFF"
        
        do {
            let color = try UIColor(hexColor)
            let (red, green, blue, alpha) = color.components
            XCTAssertEqual(255/255, red)
            XCTAssertEqual(255/255, green)
            XCTAssertEqual(255/255, blue)
            XCTAssertEqual(1.0, alpha)
        } catch {
            XCTFail("Exception should not be thrown")
        }
    }
    
    func testInitShouldCreateRedishColorWhenRedishHexColorWithNumberSignPrefix() {
        let hexColor = "#DC143C"
        
        do {
            let color = try UIColor(hexColor)
            let (red, green, blue, alpha) = color.components
            XCTAssertEqual(220/255, red)
            XCTAssertEqual(20/255, green)
            XCTAssertEqual(60/255, blue)
            XCTAssertEqual(1.0, alpha)
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
