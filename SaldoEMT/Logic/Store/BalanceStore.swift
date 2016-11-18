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
    
    fileprivate let realm: Realm
    fileprivate let balance: Balance
    
    init(realm: Realm) {
        self.realm = realm
        if realm.objects(Balance.self).count == 0 {
            balance = Balance()
            try! realm.write {
                realm.add(balance)
            }
        } else {
            balance = realm.objects(Balance.self).first!
        }
    }
    
    func getBalance() -> Balance {
        return balance
    }
    
    func addTrip(withCost tripCost: Double) throws {
        let remaining = balance.current - tripCost
        
        try realm.write {
            balance.tripsDone += 1;
            balance.tripsRemaining -= 1;
            balance.current = remaining
        }
    }
    
    func recalculateRemainingTrips(withNewTripCost newCost: Double) throws {
        let currentBalance = balance.current
        
        try realm.write {
            balance.tripsRemaining = Int(currentBalance / newCost)
        }
    }
    
    func recalculateRemainingTrips(addingToBalance amount: Double, withTripCost costPerTrip: Double) throws {
        let currentBalance = amount + balance.current
        
        try realm.write {
            balance.tripsRemaining = Int(currentBalance / costPerTrip)
            balance.current = currentBalance
        }
    }
    
    func reset() {
        balance.current = 4
        balance.tripsRemaining = 5
        balance.tripsDone = 0
    }
}
