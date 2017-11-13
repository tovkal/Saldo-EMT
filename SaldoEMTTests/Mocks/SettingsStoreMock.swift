//
//  SettingsStoreMock.swift
//  SaldoEMTTests
//
//  Created by Andrés Pizá Bückmann on 29/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation
@testable import SaldoEMT

// swiftlint:disable identifier_name
class SettingsStoreMock: SettingsStoreProtocol {
    private (set) var getSelectedFareCalled = false
    private (set) var selectedNewFareCalled = false
    private (set) var addTripCalled = false
    private (set) var addTripCost: Double?
    private (set) var recalculateRemainingTripsAddingToBalanceCalled = false
    private (set) var addMoney: Double?
    private (set) var getCurrentStateCalled = false
    private (set) var resetCalled = false

    var selectedFare: Fare?
    var lastTimestamp = 0
    var throwInsufficientBalanceException = false

    func getSelectedFare() -> Fare? {
        getSelectedFareCalled = true
        return selectedFare
    }

    func selectNewFare(_ fare: Fare) {
        selectedNewFareCalled = true
        selectedFare = fare
    }

    func addTrip(withCost: Double) throws {
        addTripCalled = true
        addTripCost = withCost

        if throwInsufficientBalanceException {
            throw DataManagerError.insufficientBalance
        }
    }

    func reset() {
        resetCalled = true
    }

    func recalculateRemainingTrips(withNewTripCost newCost: Double) {

    }

    func recalculateRemainingTrips(addingToBalance amount: Double, withTripCost costPerTrip: Double) throws {
        recalculateRemainingTripsAddingToBalanceCalled = true
        addMoney = amount
    }

    func getCurrentState(with fare: Fare) -> HomeViewModel {
        getCurrentStateCalled = true
        return HomeViewModel(currentFareName: "", tripsDone: 0, tripsRemaining: 0, balance: 0.0, imageUrl: "http://www.test.com/image.png")
    }

    func getLastTimestamp() -> Int {
        return lastTimestamp
    }

    func updateTimestamp(_ timestamp: Int) {
        lastTimestamp = timestamp
    }
}
