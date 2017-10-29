//
//  DataManagerSpec.swift
//  SaldoEMTTests
//
//  Created by Andrés Pizá Bückmann on 29/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import XCTest
@testable import SaldoEMT
import Quick
import Nimble
import RealmSwift
import SwiftyJSON

// swiftlint:disable function_body_length
class DataManagerSpec: QuickSpec {
    override func spec() {
        var dataManager: DataManager!
        var settingsStore: SettingsStoreMock!
        var fareStore: FareStoreMock!
        var jsonParser: JsonParserMock!
        var session: URLSessionMock!
        var notificationCenter: NotificationCenterMock!

        beforeEach {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
            settingsStore = SettingsStoreMock()
            jsonParser = JsonParserMock()
            fareStore = FareStoreMock(jsonParser: jsonParser)
            session = URLSessionMock()
            notificationCenter = NotificationCenterMock()
            dataManager = DataManager(settingsStore: settingsStore, fareStore: fareStore, jsonParser: jsonParser,
                                      session: session, notificationCenter: notificationCenter)
        }

        describe("init") {
            context("when no fare is selected") {
                beforeEach {
                    settingsStore.selectedFare = nil
                    _ = DataManager(settingsStore: settingsStore, fareStore: fareStore, jsonParser: jsonParser)
                }

                it("sets the first fare as selected") {
                    expect(fareStore.getFareForIdCalled).to(beTrue())
                    expect(fareStore.getFareForId).to(equal(fareStore.firstFareId))
                    expect(settingsStore.selectedNewFareCalled).to(beTrue())
                    XCTAssertEqual(settingsStore.selectedFare, fareStore.firstFare)
                }
            }

            context("when a fare is selected") {
                beforeEach {
                    settingsStore.selectedFare = fareStore.secondFare
                }

                it("does not select a fare") {
                    expect(settingsStore.getSelectedFareCalled).to(beTrue())
                    XCTAssertEqual(settingsStore.selectedFare, fareStore.secondFare)
                }
            }
        }

        describe("getAllFares") {
            it("gets all fares from fare store") {
               _ = dataManager.getAllFares()
                expect(fareStore.getAllFaresCalled).to(beTrue())
            }
        }

        describe("selectNewFare") {
            beforeEach {
                settingsStore.selectedFare = nil
            }

            it("selects a new fare") {
                dataManager.selectNewFare(fareStore.firstFare)
                expect(settingsStore.selectedNewFareCalled).to(beTrue())
                XCTAssertEqual(settingsStore.selectedFare, fareStore.firstFare)
            }
        }

        describe("getSelectedFare") {
            context("when no fare is selected") {
                beforeEach {
                    settingsStore.selectedFare = nil
                }

                it("sets the first fare as selected") {
                    let fare = dataManager.getSelectedFare()
                    expect(fareStore.getFareForIdCalled).to(beTrue())
                    expect(fareStore.getFareForId).to(equal(fareStore.firstFareId))
                    expect(settingsStore.selectedNewFareCalled).to(beTrue())
                    XCTAssertEqual(fare, fareStore.firstFare)
                }
            }

            context("when a fare is selected") {
                beforeEach {
                    settingsStore.selectedFare = fareStore.secondFare
                }

                it("does not select a fare") {
                    expect(settingsStore.getSelectedFareCalled).to(beTrue())
                    XCTAssertEqual(settingsStore.selectedFare, fareStore.secondFare)
                }
            }
        }

        describe("downloadNewFares") {
            var backgroundFetchResult: UIBackgroundFetchResult?
            let completionHandler: ((UIBackgroundFetchResult) -> Void)? = { result in backgroundFetchResult = result }

            it("fails when response is error") {
                session.error = NSError(domain: "domain", code: 0)

                dataManager.downloadNewFares(completionHandler: completionHandler)

                expect(backgroundFetchResult).to(equal(.failed))
            }

            it("fails when response has no data") {
                session.data = nil

                dataManager.downloadNewFares(completionHandler: completionHandler)

                expect(backgroundFetchResult).to(equal(.failed))
            }

            it("succeeds with new data") {
                let jsonTimestamp = 123456789
                settingsStore.lastTimestamp = jsonTimestamp - 1
                var json = JSON()
                json["timestamp"] = JSON(jsonTimestamp)
                session.data = try! json.rawData() // swiftlint:disable:this force_try

                dataManager.downloadNewFares(completionHandler: completionHandler)

                expect(settingsStore.lastTimestamp).to(equal(jsonTimestamp))
                expect(notificationCenter.postCalled).to(beTrue())
                expect(notificationCenter.notificationName).to(equal(NotificationCenterKeys.BusAndFaresUpdate))
                expect(backgroundFetchResult).to(equal(.newData))
                expect(session.dataTask.resumeWasCalled).to(beTrue())
            }

            it("succeeds without new data") {
                let jsonTimestamp = 123456789
                settingsStore.lastTimestamp = jsonTimestamp + 1
                var json = JSON()
                json["timestamp"] = JSON(jsonTimestamp)
                session.data = try! json.rawData() // swiftlint:disable:this force_try

                dataManager.downloadNewFares(completionHandler: completionHandler)

                expect(backgroundFetchResult).to(equal(.noData))
            }
        }

        describe("addTrip") {
            it("adds trip to settings") {
                let tripCost = 1.5
                let fare = fareStore.firstFare
                fare.tripCost = tripCost
                settingsStore.selectedFare = fare

                dataManager.addTrip(nil)

                expect(settingsStore.addTripCalled).to(beTrue())
                expect(settingsStore.addTripCost).to(equal(tripCost))
            }

            context("fails") {
                var errorResult: String?
                let errorHandler = { errorMessage in errorResult = errorMessage }

                it("when cost per trip not known") {
                    settingsStore.selectedFare = nil

                    dataManager.addTrip(errorHandler)

                    expect(errorResult).to(equal(DataManagerErrors.costPerTripUnknown))
                }

                it("when balance insufficient") {
                    let fare = fareStore.firstFare
                    fare.tripCost = 1.5
                    settingsStore.selectedFare = fare
                    settingsStore.throwInsufficientBalanceException = true

                    dataManager.addTrip(errorHandler)

                    expect(errorResult).to(equal(DataManagerErrors.insufficientBalance))
                }
            }
        }

        describe("addMoney") {
            it("adds amount to balance") {
                let amount = 12.3

                dataManager.addMoney(amount)

                expect(settingsStore.recalculateRemainingTripsAddingToBalanceCalled).to(beTrue())
                expect(settingsStore.addMoney).to(equal(amount))
            }
        }

        describe("getCurrentState") {
            it("returns state") {
                _ = dataManager.getCurrentState()

                expect(settingsStore.getCurrentStateCalled).to(beTrue())
            }
        }

        describe("reset") {
            it("selects first fare") {
                dataManager.reset()

                expect(settingsStore.selectedNewFareCalled).to(beTrue())
            }

            it("resets settings") {
                dataManager.reset()

                expect(settingsStore.resetCalled).to(beTrue())
            }
        }
    }
}
