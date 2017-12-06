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
    func addTrip(withCost: NSDecimalNumber) throws
    func reset()
    func recalculateRemainingTrips(withNewTripCost newCost: NSDecimalNumber) throws
    func recalculateRemainingTrips(addingToBalance amount: NSDecimalNumber, withTripCost costPerTrip: NSDecimalNumber) throws
    func getCurrentState(with fare: Fare) -> HomeViewModel
    func getLastTimestamp() -> Int
    func updateTimestamp(_ timestamp: Int)
    func setBalance(_ amount: NSDecimalNumber)
}

class SettingsStore: SettingsStoreProtocol {
    init() {
        let realm = RealmHelper.getRealm()

        if realm.isEmpty {
            do {
                try realm.write {
                    realm.add(Settings())
                }
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.firstRun)
            } catch let error as NSError {
                log.error(error)
                Crashlytics.sharedInstance().recordError(error)
                fatalError("Settings object is needed")
            }
        } else if UserDefaults.standard.bool(forKey: UserDefaultsKeys.firstRun) {
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.firstRun)
        }
    }

    func getSettings() -> Settings {
        let realm = RealmHelper.getRealm()
        return realm.objects(Settings.self).first!
    }

    func addTrip(withCost tripCost: NSDecimalNumber) throws {
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

    func recalculateRemainingTrips(withNewTripCost newCost: NSDecimalNumber) throws {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()

        try realm.write {
            settings.tripsRemaining = (settings.balance / newCost).intValueRoundDown
        }
    }

    func recalculateRemainingTrips(addingToBalance amount: NSDecimalNumber, withTripCost costPerTrip: NSDecimalNumber) throws {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()
        let currentSettings = amount + settings.balance

        try realm.write {
            settings.tripsRemaining = (currentSettings / costPerTrip).intValueRoundDown
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
                             tripsRemaining: settings.tripsRemaining, balance: settings.balance.formattedStringValue,
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

    func setBalance(_ amount: NSDecimalNumber) {
        let realm = RealmHelper.getRealm()
        let settings = getSettings()

        do {
            try realm.write {
                settings.balance = amount
            }
        } catch let error as NSError {
            log.error(error)
            Crashlytics.sharedInstance().recordError(error)
        }
    }
}
