//
//  BalanceStore.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 30/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation
import RealmSwift

class BalanceStore {

    init() {
        let realm = try! Realm()
        if realm.objects(Balance.self).count == 0 {
            try! realm.write {
                realm.add(Balance())
            }
        }
    }
    
    func getBalance() -> Balance {
        let realm = try! Realm()
        return realm.objects(Balance.self).first!
    }
    
    func addTrip(withCost tripCost: Double) throws {
        let realm = try! Realm()
        let balance = getBalance()
        let remaining = balance.current - tripCost

        try realm.write {
            balance.tripsDone += 1;
            balance.tripsRemaining -= 1;
            balance.current = remaining
        }
    }
    
    func recalculateRemainingTrips(withNewTripCost newCost: Double) throws {
        let realm = try! Realm()
        let balance = getBalance()
        let currentBalance = balance.current

        try realm.write {
            balance.tripsRemaining = Int(currentBalance / newCost)
        }
    }
    
    func recalculateRemainingTrips(addingToBalance amount: Double, withTripCost costPerTrip: Double) throws {
        let realm = try! Realm()
        let balance = getBalance()
        let currentBalance = amount + balance.current

        try realm.write {
            balance.tripsRemaining = Int(currentBalance / costPerTrip)
            balance.current = currentBalance
        }
    }
    
    func reset() {
        let realm = try! Realm()
        let balance = getBalance()

        try! realm.write {
            balance.current = 4
            balance.tripsRemaining = 5
            balance.tripsDone = 0
        }
    }
}
