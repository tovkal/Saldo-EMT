//
//  SettingsStoreSpec.swift
//  SaldoEMTTests
//
//  Created by Andrés Pizá Bückmann on 02/11/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

@testable import SaldoEMT
import Quick
import Nimble
import RealmSwift

// swiftlint:disable function_body_length
// swiftlint:disable force_try
class SettingsStoreSpec: QuickSpec {
    override func spec() {
        var settingsStore: SettingsStore!

        beforeEach {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
            settingsStore = SettingsStore()
        }

        describe("init") {
            it("creates empty settings object when realm is empty") {
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                }
                expect(realm.objects(Settings.self).isEmpty).to(beTrue())
                _ = SettingsStore()
                expect(realm.objects(Settings.self).isEmpty).to(beFalse())
            }
        }

        describe("getSettings") {
            it("returns Settings") {
                let result = settingsStore.getSettings()
                expect(result).notTo(beNil())
            }
        }

        context("Settings exist") {
            var realm: Realm!
            let balance = NSDecimalNumber(value: 1.5)
            let tripsRemaining = 1
            let tripsDone = 2
            beforeEach {
                realm = try! Realm()
                let settings = Settings()
                settings.balance = balance
                settings.tripsRemaining = tripsRemaining
                settings.tripsDone = tripsDone
                try! realm.write {
                    realm.deleteAll()
                    realm.add(settings, update: true)
                }
            }

            describe("addTrip") {
                it("updates balance and trip counts") {
                    let cost = NSDecimalNumber(value: 1.5)
                    try! settingsStore.addTrip(withCost: cost)
                    let settings = realm.objects(Settings.self).first!
                    expect(settings.tripsDone).to(equal(3))
                    expect(settings.tripsRemaining).to(equal(0))
                    expect(settings.balance).to(equal(0))
                }

                it("throws exception when balance insufficient") {
                    let cost = NSDecimalNumber(value: 15)

                    do {
                        try settingsStore.addTrip(withCost: cost)
                        XCTFail("Expected DataManagerError.insufficientBalance exception")
                    } catch let error as DataManagerError {
                        expect(error).to(equal(DataManagerError.insufficientBalance))
                    } catch {
                        XCTFail("Expected DataManagerError.insufficientBalance exception")
                    }
                }
            }

            describe("recalculateRemainingTrips") {
                it("updates remaining trips for the new trip cost") {
                    let newCost = NSDecimalNumber(value: 0.6)
                    try! settingsStore.recalculateRemainingTrips(withNewTripCost: newCost)
                    let settings = realm.objects(Settings.self).first!
                    expect(settings.tripsRemaining).to(equal(2))
                }
            }

            describe("recalculateRemainingTrips") {
                it("adds the amount to the balance and recalculates the remaining trips") {
                    let amount = NSDecimalNumber(value: 0.5)
                    let tripCost = NSDecimalNumber(value: 0.5)
                    try! settingsStore.recalculateRemainingTrips(addingToBalance: amount, withTripCost: tripCost)
                    let settings = realm.objects(Settings.self).first!
                    expect(settings.tripsRemaining).to(equal(4))
                }
            }

            describe("getSelectedFare") {
                it("returns nil when no fare is selected") {
                    let result = settingsStore.getSelectedFare()
                    expect(result).to(beNil())
                }

                context("fare is selected") {
                    var fare: Fare!
                    beforeEach {
                        fare = Fare()
                        fare.id = 1
                        let settings = realm.objects(Settings.self).first!
                        settings.currentFare = fare
                        try! realm.write {
                            realm.add(settings, update: true)
                        }

                        it("returns the selected fare") {
                            let result = settingsStore.getSelectedFare()
                            XCTAssertEqual(result, fare)
                        }
                    }
                }
            }

            describe("selectNewFare") {
                it("sets fare as selected") {
                    let fare = Fare()
                    fare.id = 2
                    settingsStore.selectNewFare(fare)
                    let settings = realm.objects(Settings.self).first!
                    XCTAssertEqual(settings.currentFare, fare)
                }
            }

            describe("getCurrentState") {
                it("returns HomeViewModel") {
                    let fareName = "test"
                    let fare = Fare()
                    fare.name = fareName
                    let result = settingsStore.getCurrentState(with: fare)
                    expect(result.currentFareName).to(equal(fareName))
                    expect(result.tripsDone).to(equal(tripsDone))
                    expect(result.tripsRemaining).to(equal(tripsRemaining))
                    expect(result.balance).to(equal(balance.formattedStringValue))
                }
            }

            describe("getLastTimestamp") {
                it("returns last timestamp") {
                    let result = settingsStore.getLastTimestamp()
                    expect(result).to(equal(0))
                }
            }

            describe("updateTimestamp") {
                it("updates timestamp") {
                    let timestamp = Int(Date().timeIntervalSince1970)
                    settingsStore.updateTimestamp(timestamp)
                    let settings = realm.objects(Settings.self).first!
                    expect(settings.lastTimestamp).to(equal(timestamp))
                }
            }
        }
    }
}
