//
//  SettingsStore.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 26/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import RealmSwift

class SettingsStore {

    init() {
        let realm = try! Realm()
        
        if realm.isEmpty {
            try! realm.write {
                realm.add(Settings())
            }
        }
    }
    
    func getSettings() -> Settings {
        let realm = try! Realm()
        return realm.objects(Settings.self).first!
    }

    func addTrip(withCost tripCost: Double) throws {
        let realm = try! Realm()
        let settings = getSettings()
        let remaining = settings.balance - tripCost

        try realm.write {
            settings.tripsDone += 1;
            settings.tripsRemaining -= 1;
            settings.balance = remaining
        }
    }

    func recalculateRemainingTrips(withNewTripCost newCost: Double) throws {
        let realm = try! Realm()
        let settings = getSettings()
        let currentSettings = settings.balance

        try realm.write {
            settings.tripsRemaining = Int(currentSettings / newCost)
        }
    }

    func recalculateRemainingTrips(addingToBalance amount: Double, withTripCost costPerTrip: Double) throws {
        let realm = try! Realm()
        let settings = getSettings()
        let currentSettings = amount + settings.balance

        try realm.write {
            settings.tripsRemaining = Int(currentSettings / costPerTrip)
            settings.balance = currentSettings
        }
    }

    func reset() {
        let realm = try! Realm()
        let settings = getSettings()

        try! realm.write {
            settings.balance = 4
            settings.tripsRemaining = 5
            settings.tripsDone = 0
        }
    }
}
