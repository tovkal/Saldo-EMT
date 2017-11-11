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

struct DataManagerErrors {
    static let costPerTripUnknown = "Cost per trip is unknown, can't add trip"
    static let insufficientBalance = "There is not enough money to pay for the trip"
    static let unknown = "Unknown error ocurred"
}

protocol DataManagerProtocol {
    init(settingsStore: SettingsStoreProtocol, fareStore: FareStoreProtocol, jsonParser: JsonParserProtocol, session: URLSessionProtocol, notificationCenter: NotificationCenterProtocol)
    func getAllFares() -> [Fare]
    func selectNewFare(_ fare: Fare)
    func addMoney(_ amount: Double)
    func reset()
    func downloadNewFares(completionHandler: ((UIBackgroundFetchResult) -> Void)?)
    func addTrip(_ onError: ((_ errorMessage: String) -> Void)?)
    func getCurrentState() -> HomeViewModel
}

class DataManager: DataManagerProtocol {
    let settingsStore: SettingsStoreProtocol
    let fareStore: FareStoreProtocol
    let jsonParser: JsonParserProtocol
    let session: URLSessionProtocol
    let notificationCenter: NotificationCenterProtocol

    // MARK: - Init

    /**
     Init Store
     
     By default bus lines and fares are extracted from a minimized json filed bundled with the app in the Assets folder.
     */
    required init(settingsStore: SettingsStoreProtocol, fareStore: FareStoreProtocol,
                  jsonParser: JsonParserProtocol, session: URLSessionProtocol = URLSession.shared,
                  notificationCenter: NotificationCenterProtocol = NotificationCenter.default) {
        self.settingsStore = settingsStore
        self.fareStore = fareStore
        self.jsonParser = jsonParser
        self.session = session
        self.notificationCenter = notificationCenter

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

            do {
                let json = try JSON(data: responseData)
                let timestamp = json["timestamp"].intValue
                let lastTimestamp = self.settingsStore.getLastTimestamp()

                // lastTimestamp is 0 when no update has ever been received
                if lastTimestamp == 0 || lastTimestamp < timestamp {
                    self.jsonParser.processJSON(json: json)
                    self.updateBalanceAfterUpdatingFares()
                    self.settingsStore.updateTimestamp(timestamp)
                    // Send updated fares notification
                    self.notificationCenter.post(name: Notification.Name(rawValue: NotificationCenterKeys.BusAndFaresUpdate), object: self)

                    log.debug("Processed new fare data")
                    completionHandler?(.newData)
                } else {
                    log.debug("No new data downloaded")
                    completionHandler?(.noData)
                }
            } catch let error as NSError {
                Crashlytics.sharedInstance().recordError(error)
                completionHandler?(.failed)
                return
            }
        }

        task.resume()
    }

    // MARK: - Settings functions

    func addTrip(_ onError: ((_ errorMessage: String) -> Void)?) {
        do {
            let cost = try getCurrentTripCost()
            try settingsStore.addTrip(withCost: cost)
        } catch DataManagerError.costPerTripUnknown {
            onError?(DataManagerErrors.costPerTripUnknown)
        } catch DataManagerError.insufficientBalance {
            onError?(DataManagerErrors.insufficientBalance)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
            onError?(DataManagerErrors.unknown)
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

        throw DataManagerError.costPerTripUnknown
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
