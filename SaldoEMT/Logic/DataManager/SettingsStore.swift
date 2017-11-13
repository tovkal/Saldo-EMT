//
//  SettingsStore.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 26/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import RealmSwift
import Crashlytics

protocol SettingsStoreProtocol {
    func getSelectedFare() -> Fare?
    func selectNewFare(_ fare: Fare)
    func addTrip(withCost: Double) throws
    func reset()
    func recalculateRemainingTrips(withNewTripCost newCost: Double) throws
    func recalculateRemainingTrips(addingToBalance amount: Double, withTripCost costPerTrip: Double) throws
    func getCurrentState(with fare: Fare) -> HomeViewModel
    func getLastTimestamp() -> Int
    func updateTimestamp(_ timestamp: Int)
}

class SettingsStore: SettingsStoreProtocol {
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

        if settings.balance < tripCost {
            throw DataManagerError.insufficientBalance
        }

        try realm.write {
            settings.tripsDone += 1
            settings.tripsRemaining -= 1
            settings.balance -= tripCost
        }
    }

    func recalculateRemainingTrips(withNewTripCost newCost: Double) throws {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()

        try realm.write {
            settings.tripsRemaining = Int(settings.balance / newCost)
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

    // Dev function
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

    func getSelectedFare() -> Fare? {
        return getSettings().currentFare
    }

    func selectNewFare(_ fare: Fare) {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()

        do {
            try realm.write {
                settings.currentFare = fare
            }
        } catch let error as NSError {
            log.error(error)
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    func getCurrentState(with fare: Fare) -> HomeViewModel {
        let settings = getSettings()
        return HomeViewModel(currentFareName: fare.name, tripsDone: settings.tripsDone,
                             tripsRemaining: settings.tripsRemaining, balance: settings.balance,
                             imageUrl: fare.imageUrl)
    }

    func getLastTimestamp() -> Int {
        return getSettings().lastTimestamp
    }

    func updateTimestamp(_ timestamp: Int) {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()

        do {
            try realm.write {
                settings.lastTimestamp = timestamp
            }
        } catch let error as NSError {
            log.error(error)
            Crashlytics.sharedInstance().recordError(error)
        }
    }
}
