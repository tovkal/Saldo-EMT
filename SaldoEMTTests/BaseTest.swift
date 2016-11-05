//
//  BaseTest.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 05/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import XCTest
import UIKit

class BaseTest: XCTestCase {
    override func setUp() {
        super.setUp()
        UIApplication.shared.delegate = MockAppDelegate()
    }
}

class MockAppDelegate: NSObject, UIApplicationDelegate {}
