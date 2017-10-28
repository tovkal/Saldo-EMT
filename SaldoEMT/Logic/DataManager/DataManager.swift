//
//  DataManager.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import Crashlytics
import RealmSwift

protocol DataManager {
    func getAllFares() -> [Fare]
    func selectNewFare(_ fare: Fare)
    func addMoney(_ amount: Double)
    func reset()
    func downloadNewFares(completionHandler: ((UIBackgroundFetchResult) -> Void)?)
    func addTrip(_ onError: ((_ errorMessage: String) -> Void)?)
    func getCurrentState() -> HomeViewModel
}

class DataManagerImpl: DataManager {
    let settingsStore: SettingsStore
    let fareStore: FareStore
    let jsonParser: JsonParser

    // MARK: - Init

    /**
     Init Store
     
     By default bus lines and fares are extracted from a minimized json filed bundled with the app in the Assets folder.
     */
    init(settingsStore: SettingsStore, fareStore: FareStore, jsonParser: JsonParser) {
        self.settingsStore = settingsStore
        self.fareStore = fareStore
        self.jsonParser = jsonParser

        // Select a default fare if none is currently selected
        _ = getSelectedFare()
    }

    // MARK: - Fare functions

    func getAllFares() -> [Fare] {
        return fareStore.getAllFares()
    }

    func selectNewFare(_ fare: Fare) {
        settingsStore.selectNewFare(fare)
    }

    func getSelectedFare() -> Fare {
        let selectedFare: Fare

        if let fare = settingsStore.getSelectedFare() {
            selectedFare = fare
        } else {
            let fare = fareStore.getFare(forId: 1).first!
            settingsStore.selectNewFare(fare)
            selectedFare = fare
        }

        return selectedFare
    }

    /**
     Update fares and bus lines.

     Downloads JSON file from AWS S3 and updates fares and bus lines in Realm.
     */
    func downloadNewFares(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        log.debug("Downloading fares json")

        let endpoint: String = "https://s3.eu-central-1.amazonaws.com/saldo-emt/fares_es.json"
        guard let url = URL(string: endpoint) else {
            log.error("Error: cannot create URL")
            completionHandler?(.failed)
            return
        }
        let urlRequest = URLRequest(url: url)

        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // make the request
        let task = session.dataTask(with: urlRequest) { (data, _, error) in

            // check for any errors
            guard error == nil else {
                log.error("error fetching fares \(error!)")
                completionHandler?(.failed)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                log.error("Error: did not receive data")
                completionHandler?(.failed)
                return
            }

            log.info("Downloaded file size is: \(Float(responseData.count) / 1000) KB")

            let realm = RealmHelper.getRealm()
            let settings = realm.objects(Settings.self).first!

            let json = JSON(data: responseData)
            let timestamp = json["timestamp"].intValue

            // Settins.lastTimestamp is 0 when a fares json file has never been processed
            if settings.lastTimestamp == 0 || settings.lastTimestamp < timestamp {
                self.jsonParser.processJSON(json: json)
                self.updateBalanceAfterUpdatingFares()

                do {
                    try realm.write {
                        settings.lastTimestamp = json["timestamp"].intValue
                    }} catch let error as NSError {
                        log.error(error)
                        Crashlytics.sharedInstance().recordError(error)
                }

                // Send updated fares notification
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationCenterKeys.BusAndFaresUpdate), object: self)

                log.debug("Processed new fare data")
                completionHandler?(.newData)
            } else {
                log.debug("No new data downloaded")
                completionHandler?(.noData)
            }
        }

        task.resume()
    }

    // MARK: - Settings functions

    func addTrip(_ onError: ((_ errorMessage: String) -> Void)?) {
        do {
            let cost = try getCurrentTripCost()
            try settingsStore.addTrip(withCost: cost)
        } catch StoreError.costPerTripUnknown {
            onError?("Cost per trip is unknown, can't add trip")
        } catch StoreError.insufficientBalance {
            onError?("There is not enough money to pay for the trip")
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
            onError?("Unknown error ocurred")
        }
    }

    func addMoney(_ amount: Double) {
        do {
            let costPerTrip = try getCurrentTripCost()
            try settingsStore.recalculateRemainingTrips(addingToBalance: amount, withTripCost: costPerTrip)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    func getCurrentState() -> HomeViewModel {
        let fare = getSelectedFare()
        return settingsStore.getCurrentState(with: fare)
    }

    // MARK: Dev functions

    func reset() {
        log.debug("Fare before reset: \(self.getSelectedFare())")
        selectNewFare(fareStore.getFare(forId: 1).first!)
        log.debug("Fare after reset: \(self.getSelectedFare())")
        settingsStore.reset()
    }

    // MARK: - Private Functions

    private func getCurrentTripCost() throws -> Double {
        if let tripCost = settingsStore.getSelectedFare()?.tripCost {
            return tripCost
        }

        throw StoreError.costPerTripUnknown
    }

    private func updateBalanceAfterUpdatingFares() {
        do {
            let newCost = try getCurrentTripCost()

            try settingsStore.recalculateRemainingTrips(withNewTripCost: newCost)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }
}
