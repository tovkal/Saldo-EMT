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
    private let realm = try! Realm()
    
    // MARK: - Public
    
    func getSelectedFare() -> String {
        let results = getCurrentFare()
        if results.count == 1 {
            return results[0].name
        } else {
            return "ERROR"
        }
    }
    
    func setNewCurrentFare(fare: Fare) {
        let oldFare = getCurrentFare()
        let newFare = getFareForName(fare.name)
        
        if oldFare.count == 1 && newFare.count == 1 {
            try! realm.write {
                oldFare[0].current = false
                newFare[0].current = true
            }
        }
    }
    
    func getAllFares() -> Results<Fare> {
        return realm.objects(Fare)
    }
    
    func getTripsDone() -> Int {
        return realm.objects(Balance)[0].tripsDone
    }
    
    func getTripsRemaining() -> Int {
        return realm.objects(Balance)[0].tripsRemaining
    }
    
    func getRemainingBalance() -> Double {
        return realm.objects(Balance)[0].remaining
    }
    
    func getCurrentTripCost() throws -> Double {
        let results = getCurrentFare()
        if results.count == 1 {
            return results[0].tripCost
        }
        
        throw StoreError.CostPerTripUnknown
    }
    
    func addTrip() -> String? {
        do {
            let costPerTrip = try getCurrentTripCost()

            if getRemainingBalance() < costPerTrip {
                throw StoreError.InsufficientBalance
            }
            
            let remaining = realm.objects(Balance)[0].remaining - costPerTrip
            
            try realm.write {
                realm.objects(Balance)[0].tripsDone++;
                realm.objects(Balance)[0].tripsRemaining--;
                realm.objects(Balance)[0].remaining = remaining
            }
        } catch StoreError.CostPerTripUnknown {
            return "Cost per trip is unknown, can't add trip"
        } catch StoreError.InsufficientBalance {
            return "There is not enough money to pay for the trip"
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
            return "Unknown error ocurred"
        }
        
        return nil
    }
    
    // MARK: - Init
    
    private init() {
        if let json = getFileData() {
            parseBusLines(json)
            parseFares(json)
        }
        
        initBalance()
    }
    
    private func initBalance() {
        if realm.objects(Balance).count == 0 {
            try! realm.write {
                realm.add(Balance())
                
                realm.objects(Balance)[0].remaining = 4
                realm.objects(Balance)[0].tripsRemaining = 5
            }
        }
    }
    
    // MARK: - JSON Processing
    
    private func getFileData() -> JSON? {
        if let path = NSBundle.mainBundle().pathForResource("fares_es", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                return JSON(data: data)
            } catch let error as NSError {
                Crashlytics.sharedInstance().recordError(error)
            }
        } else {
            print("Invalid filename/path.")
        }
        
        return nil
    }
    
    private func parseBusLines(json: JSON) {
        for (_, line) in json["lines"] {
            for (lineNumber, lineInfo) in line {
                let busLine = BusLine()
                
                busLine.number = Int(lineNumber)!
                busLine.hexColor = lineInfo["color"].stringValue
                busLine.name = lineInfo["name"].stringValue
                
                if realm.objectForPrimaryKey(BusLine.self, key: busLine.number) == nil { // Add if not exists
                    try! realm.write {
                        realm.add(busLine, update: false)
                    }
                }
            }
        }
    }
    
    private func parseFares(json: JSON) {
        var firstCurrent = true
        
        for (_, fare) in json["fares"] {
            for (fareNumber, fareInfo) in fare {
                
                let fare = Fare()
                
                fare.name = fareInfo["name"].stringValue
                fare.number = fareNumber
                fare.rides.value = fareInfo["rides"].int
                fare.cost = fareInfo["price"].doubleValue
                fare.days.value = fareInfo["days"].int
                for busLine in getBusLinesForLineNumbers(fareInfo["lines"].arrayObject as! [Int]) {
                    fare.lines.append(busLine)
                }
                
                if fare.name == "Residentes" && firstCurrent {
                    fare.current = true
                    firstCurrent = false
                }
                
                if let rides = fare.rides.value {
                    fare.tripCost = fare.cost / Double(rides)
                } else {
                    fare.tripCost = fare.cost
                }
                
                if realm.objectForPrimaryKey(Fare.self, key: fare.number) == nil { // Add if not exists
                    try! realm.write {
                        realm.add(fare, update: false)
                    }
                }
            }
        }
    }
    
    // MARK: - Realm private functions
    
    private func getCurrentFare() -> Results<Fare> {
        let predicate = NSPredicate(format: "current == YES")
        return realm.objects(Fare).filter(predicate)
    }
    
    private func getFareForName(fareName: String) -> Results<Fare> {
        let predicate = NSPredicate(format: "name == %@", fareName)
        return realm.objects(Fare).filter(predicate)
    }
    
    private func getBusLinesForLineNumbers(busLines: [Int]) -> Results<BusLine> {
        let predicate = NSPredicate(format: "number IN %@", busLines)
        return realm.objects(BusLine).filter(predicate)
    }
}
