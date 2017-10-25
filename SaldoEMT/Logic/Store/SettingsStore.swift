//
//  SettingsStore.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 26/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import RealmSwift
import Crashlytics

class SettingsStore {

    init() {
        let realm = RealmHelper.getRealm()

        if realm.isEmpty {
            do {
                try realm.write {
                    realm.add(Settings())
                }
            } catch let error as NSError {
                log.error(error)
                Crashlytics.sharedInstance().recordError(error)
                fatalError("Settings object is needed")
            }
        }
    }

    func getSettings() -> Settings {
        let realm = RealmHelper.getRealm()
        return realm.objects(Settings.self).first!
    }

    func addTrip(withCost tripCost: Double) throws {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()
        let remaining = settings.balance - tripCost

        try realm.write {
            settings.tripsDone += 1
            settings.tripsRemaining -= 1
            settings.balance = remaining
        }
    }

    func recalculateRemainingTrips(withNewTripCost newCost: Double) throws {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()
        let currentSettings = settings.balance

        try realm.write {
            settings.tripsRemaining = Int(currentSettings / newCost)
        }
    }

    func recalculateRemainingTrips(addingToBalance amount: Double, withTripCost costPerTrip: Double) throws {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()
        let currentSettings = amount + settings.balance

        try realm.write {
            settings.tripsRemaining = Int(currentSettings / costPerTrip)
            settings.balance = currentSettings
        }
    }

    func reset() {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()

        do {
            try realm.write {
                settings.balance = 4
                settings.tripsRemaining = 5
                settings.tripsDone = 0
            }
        } catch let error as NSError {
            log.error(error)
            Crashlytics.sharedInstance().recordError(error)
        }
    }
}
