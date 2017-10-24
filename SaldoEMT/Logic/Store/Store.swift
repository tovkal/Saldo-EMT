//
//  Store.swift
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

class Store {
    
    static let sharedInstance = Store()
    
    fileprivate let settingsStore: SettingsStore
    fileprivate let fareStore: FareStore
    fileprivate let jsonParser: JsonParser
    
    // MARK: - Init
    
    /**
     Init Store
     
     By default bus lines and fares are extracted from a minimized json filed bundled with the app in the Assets folder.
     */
    fileprivate init() {
        settingsStore = SettingsStore()
        fareStore = FareStore()
        jsonParser = JsonParser()
        
        if fareStore.getAllFares().isEmpty {
            if let json = getFileData() {
                jsonParser.processJSON(json: json)
                log.debug("finished parsing file")
            }
        }
    }
    
    /**
     If there is no selected fare, select default (Resident for urban zone)
     */
    func initFare() {
        let settings = settingsStore.getSettings()
        if settings.currentFare == -1 {
            let results = fareStore.getFare(forId: 1).first
            
            if let fare = results {
                let realm = try! Realm()
                try! realm.write {
                    settings.currentFare = fare.id
                }
            }
        }
    }
    
    // MARK: - Public
    
    /**
     Get current selected fare.
     
     @return Selected fare. If no fare is selected returns nil.
     */
    func getSelectedFare() -> String? {
        let results = getCurrentFare()
        if let fare = results.first {
            return fare.name
        } else {
            return nil
        }
    }
    
    func setNewCurrentFare(_ fare: Fare) {
        let realm = try! Realm()
        let settings = settingsStore.getSettings()
        
        try! realm.write {
            settings.currentFare = fare.id
        }
    }
    
    func getCurrentTripCost() throws -> Double {
        let results = getCurrentFare()
        if let fare = results.first {
            return fare.tripCost
        }
        
        throw StoreError.costPerTripUnknown
    }
    
    // MARK: User actions
    
    func addTrip() -> String? {
        do {
            let cost = try getCurrentTripCost()
            let settings = getSettings()
            
            if settings.balance < cost {
                throw StoreError.insufficientBalance
            }
            
            try settingsStore.addTrip(withCost: cost)
        } catch StoreError.costPerTripUnknown {
            return "Cost per trip is unknown, can't add trip"
        } catch StoreError.insufficientBalance {
            return "There is not enough money to pay for the trip"
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
            return "Unknown error ocurred"
        }
        
        return nil
    }
    
    func addMoney(_ amount: Double) {
        do {
            let costPerTrip = try getCurrentTripCost()
            
            try settingsStore.recalculateRemainingTrips(addingToBalance: amount, withTripCost: costPerTrip)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    // MARK: Dev functions
    func reset() {
        log.debug("Fare before reset: \(self.getSelectedFare() ?? "unknown")")
        
        setNewCurrentFare(fareStore.getFare(forId: 1).first!)
        
        log.debug("Fare after reset: \(self.getSelectedFare() ?? "unknown")")


        settingsStore.reset()
    }
    
    /**
     Update fares and bus lines.
     
     Downloads JSON file from AWS S3 and updates fares and bus lines in Realm.
     */
    func updateFares(performFetchWithCompletionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        log.debug("Downloading fares json")
        
        let endpoint: String = "https://s3.eu-central-1.amazonaws.com/saldo-emt/fares_es.json"
        guard let url = URL(string: endpoint) else {
            log.error("Error: cannot create URL")
            
            if let completionHandler = performFetchWithCompletionHandler {
                completionHandler(.failed)
            }
            
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                log.error("error fetching fares")
                log.error(error!)
                
                if let completionHandler = performFetchWithCompletionHandler {
                    completionHandler(.failed)
                }
                
                return
            }
            // make sure we got data
            guard let responseData = data else {
                log.error("Error: did not receive data")
                
                if let completionHandler = performFetchWithCompletionHandler {
                    completionHandler(.failed)
                }
                
                return
            }
            
            log.info("Downloaded file size is: \(Float(responseData.count) / 1000) KB")

            let realm = try! Realm()
            let settings = realm.objects(Settings.self).first!

            let json = JSON(data: responseData)
            let timestamp = json["timestamp"].intValue

            // Settins.lastTimestamp is 0 when a fares json file has never been processed
            if settings.lastTimestamp == 0 || settings.lastTimestamp < timestamp {
                self.jsonParser.processJSON(json: json)
                self.updateBalanceAfterUpdatingFares()

                try! realm.write {
                    settings.lastTimestamp = json["timestamp"].intValue
                }
                
                // Send updated fares notification
                NotificationCenter.default.post(name: Notification.Name(rawValue: BUS_AND_FARES_UPDATE), object: self)
                
                log.debug("Processed new fare data")
                
                if let completionHandler = performFetchWithCompletionHandler {
                    completionHandler(.newData)
                }
            } else {
                log.debug("No new data downloaded")
                
                if let completionHandler = performFetchWithCompletionHandler {
                    completionHandler(.noData)
                }
            }
        }
        
        task.resume()
    }

    fileprivate func getFileData() -> JSON? {
        if let path = Bundle.main.path(forResource: "fares_es", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                return JSON(data: data)
            } catch let error as NSError {
                Crashlytics.sharedInstance().recordError(error)
            }
        } else {
            log.error("Invalid filename/path.")
        }

        return nil
    }
    
    // MARK: - Realm private functions
    fileprivate func updateBalanceAfterUpdatingFares() {
        do {
            let newCost = try getCurrentTripCost()
            
            try settingsStore.recalculateRemainingTrips(withNewTripCost: newCost)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    // MARK: - Fare functions
    
    func getAllFares() -> [Fare] {
        return fareStore.getAllFares()
    }
    
    fileprivate func getCurrentFare() -> [Fare] {
        return fareStore.getFare(forId: settingsStore.getSettings().currentFare)
    }
    
    // MARK: - Settings functions
    
    func getSettings() -> Settings {
        return settingsStore.getSettings()
    }
}
