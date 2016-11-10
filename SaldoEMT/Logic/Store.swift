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
    
    // MARK: - Init
    
    /**
     Init Store
     
     By default bus lines and fares are extracted from a minimized json filed bundled with the app in the Assets folder.
     */
    fileprivate init() {
        let realm = try! Realm()
                
        if realm.isEmpty {
            initSettings()
            
            if let json = getFileData() {
                processJSON(json: json, realm: realm)
                log.debug("finished parsing file")
            }
        }
        
        initBalance(realm)
    }
    
    fileprivate func initBalance(_ realm: Realm) {
        if realm.objects(Balance.self).count == 0 {
            try! realm.write {
                realm.add(Balance())
                
                realm.objects(Balance.self).first!.remaining = 4
                realm.objects(Balance.self).first!.tripsRemaining = 5
            }
        }
    }
    
    /**
     If there is no selected fare, select default (Resident for urban zone)
     */
    func initFare() {
        let realm = try! Realm()
        let settings = realm.objects(Settings.self).first!
        if settings.currentFare == -1 {
            let results = getFare(forId: 1).first
            
            if let fare = results {
                let settings = realm.objects(Settings.self).first!
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
        let settings = realm.objects(Settings.self).first!
        
        try! realm.write {
            settings.currentFare = fare.id
        }
    }
    
    func getAllFares() -> Results<Fare> {
        let realm = try! Realm()
        return realm.objects(Fare.self)
    }
    
    func getTripsDone() -> Int {
        let realm = try! Realm()
        return realm.objects(Balance.self).first!.tripsDone
    }
    
    func getTripsRemaining() -> Int {
        let realm = try! Realm()
        return realm.objects(Balance.self).first!.tripsRemaining
    }
    
    func getRemainingBalance() -> Double {
        let realm = try! Realm()
        return realm.objects(Balance.self).first!.remaining
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
        let realm = try! Realm()
        do {
            let costPerTrip = try getCurrentTripCost()
            
            if getRemainingBalance() < costPerTrip {
                throw StoreError.insufficientBalance
            }
            
            let remaining = realm.objects(Balance.self).first!.remaining - costPerTrip
            
            try realm.write {
                realm.objects(Balance.self).first!.tripsDone += 1;
                realm.objects(Balance.self).first!.tripsRemaining -= 1;
                realm.objects(Balance.self).first!.remaining = remaining
            }
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
        let realm = try! Realm()
        do {
            
            let remaining = amount + realm.objects(Balance.self).first!.remaining
            let costPerTrip = try getCurrentTripCost()
            
            try realm.write {
                realm.objects(Balance.self).first!.tripsRemaining = Int(remaining / costPerTrip)
                realm.objects(Balance.self).first!.remaining = remaining
            }
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    // MARK: Dev functions
    func reset() {
        let realm = try! Realm()
        
        log.debug("Fare before reset: \(self.getSelectedFare())")
        
        setNewCurrentFare(getFare(forId: 1).first!)
        
        log.debug("Fare after reset: \(self.getSelectedFare())")
        
        try! realm.write {
            if realm.objects(Balance.self).count == 0 {
                realm.add(Balance())
            }
            
            realm.objects(Balance.self).first!.remaining = 4
            realm.objects(Balance.self).first!.tripsRemaining = 4
            realm.objects(Balance.self).first!.tripsDone = 0
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
            
            let realm = try! Realm()
            let json = JSON(data: responseData)
            if self.isNewUpdate(json: json, realm: realm) {
                self.processJSON(json: json, realm: realm)
                self.updateBalanceAfterUpdatingFares()
                
                let settings = realm.objects(Settings.self).first!
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
    
    // MARK: - JSON Processing
    
    fileprivate func processJSON(json: JSON, realm: Realm) {
        parseBusLines(json, realm: realm)
        parseFares(json, realm: realm)
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
                let busLine = BusLine()
                
                busLine.number = Int(lineNumber)!
                busLine.hexColor = lineInfo["color"].stringValue
                busLine.name = lineInfo["name"].stringValue
                
                try! realm.write {
                    // With update true objects with a primary key (BusLine has one) get updated when they already exist or inserted when not
                    realm.add(busLine, update: true)
                }
            }
        }
    }
    
    fileprivate func parseFares(_ json: JSON, realm: Realm) {
        for (_, fare) in json["fares"] {
            for (fareNumber, fareInfo) in fare {
                
                let fare = Fare()
                
                fare.name = fareInfo["name"].stringValue
                fare.id = Int(fareNumber)!
                fare.rides.value = fareInfo["rides"].int
                fare.cost = fareInfo["price"].doubleValue
                fare.days.value = fareInfo["days"].int
                for busLine in getBusLinesForLineNumbers(fareInfo["lines"].arrayObject as! [Int]) {
                    fare.lines.append(busLine)
                }
                
                if let rides = fare.rides.value {
                    fare.tripCost = fare.cost / Double(rides)
                } else {
                    fare.tripCost = fare.cost
                }
                
                try! realm.write {
                    // With update true objects with a primary key (BusLine has one) get updated when they already exist or inserted when not
                    realm.add(fare, update: true)
                }
            }
        }
    }
    
    // MARK: - Realm private functions
    
    fileprivate func getCurrentFare() -> Results<Fare> {
        let realm = try! Realm()
        let settings = realm.objects(Settings.self).first!
        return getFare(forId: settings.currentFare)
    }
    
    fileprivate func getFare(forName fareName: String) -> Results<Fare> {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "name == %@", fareName)
        return realm.objects(Fare.self).filter(predicate)
    }
    
    fileprivate func getFare(forId fareId: Int) -> Results<Fare> {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id == %d", fareId)
        return realm.objects(Fare.self).filter(predicate)
    }
    
    fileprivate func getBusLinesForLineNumbers(_ busLines: [Int]) -> Results<BusLine> {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "number IN %@", busLines)
        return realm.objects(BusLine.self).filter(predicate)
    }
    
    fileprivate func updateBalanceAfterUpdatingFares() {
        let realm = try! Realm()
        do {
            let costPerTrip = try getCurrentTripCost()
            
            let remaining = realm.objects(Balance.self).first!.remaining - costPerTrip
            
            try realm.write {
                realm.objects(Balance.self).first!.tripsDone += 1;
                realm.objects(Balance.self).first!.tripsRemaining -= 1;
                realm.objects(Balance.self).first!.remaining = remaining
            }
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    // MARK: - Setting functions
    
    fileprivate func initSettings() {
        let realm = try! Realm()
        let settings = Settings()
        
        try! realm.write {
            realm.add(settings)
        }
    }
    
    fileprivate func isNewUpdate(json: JSON, realm: Realm) -> Bool {
        let settings = realm.objects(Settings.self).first!
        let timestamp = json["timestamp"].intValue
        
        log.debug("settings timestamp < downloaded timestamp: \(settings.lastTimestamp) < \(timestamp)")
        
        // Settins.lastTimestamp is 0 when a fares json file has never been processed
        return settings.lastTimestamp == 0 || settings.lastTimestamp < timestamp
    }
}
