//
//  StoreTests.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 05/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import XCTest
import RealmSwift
@testable import SaldoEMT

class StoreTests: BaseTest {

    func testInit() {print("test init")
        let realm = try! Realm() // swiftlint:disable:this force_try
        _ = Store.sharedInstance

        validateSettings(realm: realm)
    }

    fileprivate func validateSettings(realm: Realm) {
        print(realm.configuration.inMemoryIdentifier ?? "no inmemory id")

        XCTAssertEqual(realm.objects(Fare.self).count, 25)
        XCTAssertEqual(realm.objects(Settings.self).count, 1)
    }
}
