//
//  FareStoreMock.swift
//  SaldoEMTTests
//
//  Created by Andrés Pizá Bückmann on 29/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation
@testable import SaldoEMT

class FareStoreMock: FareStoreProtocol {
    let firstFareName = "first_fare"
    let firstFareId = 1
    let secondFareName = "second_fare"
    let secondFareId = 2
    let firstFare: Fare
    let secondFare: Fare

    private (set) var getAllFaresCalled = false
    private (set) var getFareForNameCalled = false
    private (set) var getFareForName: String?
    private (set) var getFareForIdCalled = false
    private (set) var getFareForId: Int?

    required init(jsonParser: JsonParserProtocol) {
        firstFare = Fare()
        secondFare = Fare()
        firstFare.name = firstFareName
        firstFare.id = firstFareId
        secondFare.name = secondFareName
        secondFare.id = secondFareId
    }

    func getAllFares() -> [Fare] {
        getAllFaresCalled = true
        return [firstFare, secondFare]
    }

    func getFare(forName fareName: String) -> [Fare] {
        getAllFaresCalled = true
        getFareForName = fareName

        switch fareName {
        case firstFareName:
            return [firstFare]
        case secondFareName:
            return [secondFare]
        default:
            return [Fare]()
        }
    }

    func getFare(forId fareId: Int) -> [Fare] {
        getFareForIdCalled = true
        getFareForId = fareId

        switch fareId {
        case firstFareId:
            return [firstFare]
        case secondFareId:
            return [secondFare]
        default:
            return [Fare]()
        }
    }
}
