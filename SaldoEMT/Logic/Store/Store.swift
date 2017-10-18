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
    
    fileprivate let realm: Realm
    fileprivate let settingsStore: SettingsStore
    fileprivate let fareStore: FareStore
    fileprivate let balanceStore: BalanceStore
    
    // MARK: - Init
    
    /**
     Init Store
     
     By default bus lines and fares are extracted from a minimized json filed bundled with the app in the Assets folder.
     */
    fileprivate init() {
        realm = try! Realm()
        settingsStore = SettingsStore(realm: realm)
        fareStore = FareStore(realm: realm)
        balanceStore = BalanceStore(realm: realm)
        
        if fareStore.getAllFares().isEmpty {
            if let json = getFileData() {
                processJSON(json: json, realm: realm)
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
        let settings = realm.objects(Settings.self).first!
        
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
            
            if getRemainingBalance() < cost {
                throw StoreError.insufficientBalance
            }
            
            try balanceStore.addTrip(withCost: cost)
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
            
            try balanceStore.recalculateRemainingTrips(addingToBalance: amount, withTripCost: costPerTrip)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    // MARK: Dev functions
    func reset() {
        log.debug("Fare before reset: \(self.getSelectedFare() ?? "unknown")")
        
        setNewCurrentFare(fareStore.getFare(forId: 1).first!)
        
        log.debug("Fare after reset: \(self.getSelectedFare() ?? "unknown")")
        
        try! realm.write {
            balanceStore.reset()
        }
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
            
            let json = JSON(data: responseData)
            if self.settingsStore.isNewUpdate(timestamp: json["timestamp"].intValue) {
                self.processJSON(json: json, realm: self.realm)
                self.updateBalanceAfterUpdatingFares()
                
                let settings = self.realm.objects(Settings.self).first!
                try! self.realm.write {
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
    
    // MARK: - JSON Processing
    
    fileprivate func processJSON(json: JSON, realm: Realm) {
        parseBusLines(json, realm: realm)
        parseFares(json)
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
    
    fileprivate func parseBusLines(_ json: JSON, realm: Realm) {
        for (_, line) in json["lines"] {
            for (lineNumber, lineInfo) in line {
                
                // TODO: Move to BusLineStore
                let busLine = BusLine()
                
                busLine.number = Int(lineNumber)!
                busLine.hexColor = lineInfo["color"].stringValue
                busLine.name = lineInfo["name"].stringValue
                
                try! realm.write {
                    // With update true objects with a primary key (BusLine has one) get updated when they already exist or inserted when not
                    realm.add(busLine, update: true)
                }
                
                // END
            }
        }
    }
    
    // MARK: - Realm private functions
    
    // TODO: Move to BusLineStore
    fileprivate func getBusLinesForLineNumbers(_ busLines: [Int]) -> [BusLine] {
        let predicate = NSPredicate(format: "number IN %@", busLines)
        return Array(realm.objects(BusLine.self).filter(predicate))
    }
    
    fileprivate func updateBalanceAfterUpdatingFares() {
        do {
            let newCost = try getCurrentTripCost()
            
            try balanceStore.recalculateRemainingTrips(withNewTripCost: newCost)
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
    
    fileprivate func parseFares(_ json: JSON) {
        for (_, fare) in json["fares"] {
            for (fareNumber, fareInfo) in fare {
                fareStore.storeFare(id: Int(fareNumber)!, name: fareInfo["name"].stringValue, rides: fareInfo["rides"].int, price: fareInfo["price"].doubleValue, days: fareInfo["days"].int, busLines: getBusLinesForLineNumbers(fareInfo["lines"].arrayObject as! [Int]))
            }
        }
    }
    
    // MARK: - Balance functions
    
    func getTripsDone() -> Int {
        return balanceStore.getBalance().tripsDone
    }
    
    func getTripsRemaining() -> Int {
        return balanceStore.getBalance().tripsRemaining
    }
    
    func getRemainingBalance() -> Double {
        return balanceStore.getBalance().current
    }
}
