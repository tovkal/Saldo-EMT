//
//  BusLineTests.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 12/10/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import XCTest
@testable import SaldoEMT

class BusLineTests: XCTestCase {
    
    let lineNumber = "1"
    let lineColor = UIColor.redColor()
    let lineName = "Universitat"
    
    var busLine: BusLine?
    
    override func setUp() {
        super.setUp()
        
        busLine = BusLine(number: lineNumber, color: lineColor, name: lineName)
    }
    
    func testInit() {
        
        if let busLine = busLine {
            
            XCTAssertEqual(lineNumber, busLine.number, "The bus line number should be \(lineNumber) but it's \(busLine.number)")
            XCTAssertEqual(lineColor, busLine.color, "The bus line color should be \(lineColor) but it's \(busLine.color)")
            XCTAssertEqual(lineName, busLine.name, "The bus line number should be \(lineName) but it's \(busLine.name)")
        }
    }
    
    func testEquatable() {
       let otherBusLine = BusLine(number: lineNumber, color: lineColor, name: lineName)
        
        if let busLine = busLine {
            XCTAssertTrue(busLine == otherBusLine)
        }
    }
    
    func testNotEquatable() {
        let otherBusLine = BusLine(number: "2", color: lineColor, name: lineName)
        
        if let busLine = busLine {
            XCTAssertFalse(busLine == otherBusLine)
        }
    }
}
