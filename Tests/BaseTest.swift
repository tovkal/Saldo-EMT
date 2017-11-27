//
//  BaseTest.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 05/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import XCTest
import RealmSwift

class BaseTest: XCTestCase {

    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
}
