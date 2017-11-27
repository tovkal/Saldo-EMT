//
//  FareStoreSpec.swift
//  SaldoEMTTests
//
//  Created by Andrés Pizá Bückmann on 30/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

@testable import SaldoEMT
import Quick
import Nimble
import RealmSwift
import SwiftyJSON

class FareStoreSpec: QuickSpec {
    override func spec() {
        var fareStore: FareStore!

        beforeEach {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
            fareStore = FareStore()
        }

        describe("init") {
            context("realm is not empty") {
                beforeEach {
                    let fare = Fare()
                    fare.id = 1
                    let realm = try! Realm() // swiftlint:disable:this force_try
                    try! realm.write { // swiftlint:disable:this force_try
                        realm.deleteAll()
                        realm.add(fare)
                    }
                }
            }
        }

        context("realm has a fare") {
            var fare: Fare?
            let fareId = 1
            let fareName = "fareName"
            let busLineType = "busLineType"
            beforeEach {
                fare = Fare()
                fare?.id = fareId
                fare?.name = fareName
                fare?.busLineType = busLineType
                let realm = try! Realm() // swiftlint:disable:this force_try
                try! realm.write { // swiftlint:disable:this force_try
                    realm.deleteAll()
                    realm.add(fare!)
                }
            }

            describe("getAllFares") {
                it("returns all fares in realm") {
                    let result = fareStore.getAllFares()
                    XCTAssertEqual(result[0], fare)
                }
            }

            describe("getFareForName") {
                it("returns fare for given name") {
                    let result = fareStore.getFare(for: fareName, and: busLineType)
                    XCTAssertEqual(result, fare)
                }
            }

            describe("getFareForId") {
                it("returns fare for given id") {
                    let result = fareStore.getFare(forId: fareId)
                    XCTAssertEqual(result[0], fare)
                }
            }
        }
    }
}
