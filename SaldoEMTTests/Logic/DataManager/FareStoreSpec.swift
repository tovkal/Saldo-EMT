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

// swiftlint:disable function_body_length
class FareStoreSpec: QuickSpec {
    override func spec() {
        var fareStore: FareStore!
        var jsonParser: JsonParserMock!

        beforeEach {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
            jsonParser = JsonParserMock()
            fareStore = FareStore(jsonParser: jsonParser)
        }

        describe("init") {
            context("realm is empty") {
                it("parses fare file") {
                    _ = FareStore(jsonParser: jsonParser)
                    expect(jsonParser.processJSONCalled).to(beTrue())
                }
            }

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

                it("does not parse fare file") {
                    jsonParser = JsonParserMock()
                    _ = FareStore(jsonParser: jsonParser)
                    expect(jsonParser.processJSONCalled).to(beFalse())
                }
            }
        }

        context("realm has a fare") {
            var fare: Fare?
            let fareId = 1
            let fareName = "fareName"
            beforeEach {
                fare = Fare()
                fare?.id = fareId
                fare?.name = fareName
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
                    let result = fareStore.getFare(forName: fareName)
                    XCTAssertEqual(result[0], fare)
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