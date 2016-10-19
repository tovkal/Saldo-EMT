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
    fileprivate let realm = try! Realm()
    
    // MARK: - Public
    
    func getSelectedFare() -> String {
        let results = getCurrentFare()
        if results.count == 1 {
            return results[0].name
        } else {
            return "ERROR"
        }
    }
    
    func setNewCurrentFare(_ fare: Fare) {
        let oldFare = getCurrentFare()
        let newFare = getFare(forName: fare.name)
        
        if oldFare.count == 1 && newFare.count == 1 {
            try! realm.write {
                oldFare[0].current = false
                newFare[0].current = true
            }
        } else {
            
            for fare in newFare {
                print(fare.name)
            }
            
            
            
            print("Old fare count: \(oldFare.count), New fare cound: \(newFare.count)")
            //Crashlytics.sharedInstance().reco
            //Crashlytics.sharedInstance().recordCustomExceptionName("Fare Swap Error", reason: "Old fare count: \(oldFare.count), New fare cound: \(newFare.count)", frameArray: [])
        }
    }
    
    func getAllFares() -> Results<Fare> {
        return realm.objects(Fare.self)
    }
    
    func getTripsDone() -> Int {
        return realm.objects(Balance.self)[0].tripsDone
    }
    
    func getTripsRemaining() -> Int {
        return realm.objects(Balance.self)[0].tripsRemaining
    }
    
    func getRemainingBalance() -> Double {
        return realm.objects(Balance.self)[0].remaining
    }
    
    func getCurrentTripCost() throws -> Double {
        let results = getCurrentFare()
        if results.count == 1 {
            return results[0].tripCost
        }
        
        throw StoreError.costPerTripUnknown
    }
    
    func addTrip() -> String? {
        do {
            let costPerTrip = try getCurrentTripCost()
            
            if getRemainingBalance() < costPerTrip {
                throw StoreError.insufficientBalance
            }
            
            let remaining = realm.objects(Balance.self)[0].remaining - costPerTrip
            
            try realm.write {
                realm.objects(Balance.self)[0].tripsDone += 1;
                realm.objects(Balance.self)[0].tripsRemaining -= 1;
                realm.objects(Balance.self)[0].remaining = remaining
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
        do {
            
            let remaining = amount + realm.objects(Balance.self)[0].remaining
            let costPerTrip = try getCurrentTripCost()
            
            try realm.write {
                realm.objects(Balance.self)[0].tripsRemaining = Int(remaining / costPerTrip)
                realm.objects(Balance.self)[0].remaining = remaining
            }
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    func reset() {
        
        
        print("Fare before reset: \(getSelectedFare())")
        
        setNewCurrentFare(getFare(forName: "No residentes")[0])
        
        print("Fare after reset: \(getSelectedFare())")
        
        try! realm.write {
            if realm.objects(Balance.self).count == 0 {
                realm.add(Balance())
            }
            
            realm.objects(Balance.self)[0].remaining = 4
            realm.objects(Balance.self)[0].tripsRemaining = 5
            realm.objects(Balance.self)[0].tripsDone = 0;
        }
    }
    
    // MARK: - Init
    
    fileprivate init() {
        
        // TODO Rethink this bit
        /*if let json = fetchFares() {
            parseBusLines(json)
            parseFares(json)
        }*/
        
        fetchFares()
        
        initBalance()
    }
    
    fileprivate func initBalance() {
        if realm.objects(Balance.self).count == 0 {
            try! realm.write {
                realm.add(Balance())
                
                realm.objects(Balance.self)[0].remaining = 4
                realm.objects(Balance.self)[0].tripsRemaining = 5
            }
        }
    }
    
    // MARK: - JSON Processing
    
    fileprivate func processData(json: JSON) {
        print(json)
        parseBusLines(json)
        parseFares(json)
    }
    
    fileprivate func fetchFares() {
        let endpoint: String = "https://s3.eu-central-1.amazonaws.com/saldo-emt/fares_es.json"
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create URL")
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
                print("error fetching fares")
                print(error)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            self.processData(json: JSON(data: responseData))
            // parse the result as JSON, since that's what the API provides
            /*do {
                //return JSON(data: responseData)
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                // now we have the todo, let's just print it to prove we can access it
                print("The todo is: " + todo.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let todoTitle = todo["title"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                print("The title is: " + todoTitle)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }*/
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
            print("Invalid filename/path.")
        }
        
        return nil
    }
    
    fileprivate func parseBusLines(_ json: JSON) {
        for (_, line) in json["lines"] {
            for (lineNumber, lineInfo) in line {
                let busLine = BusLine()
                
                busLine.number = Int(lineNumber)!
                busLine.hexColor = lineInfo["color"].stringValue
                busLine.name = lineInfo["name"].stringValue
                
                if realm.object(ofType: BusLine.self, forPrimaryKey: busLine.number) == nil { // Add if not exists
                    try! realm.write {
                        realm.add(busLine, update: false)
                    }
                }
            }
        }
    }
    
    fileprivate func parseFares(_ json: JSON) {
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
                
                print("Add fare: \(fare.name)")
                
                if realm.object(ofType: Fare.self, forPrimaryKey: fare.number) == nil { // Add if not exists
                    try! realm.write {
                        realm.add(fare, update: false)
                    }
                }
            }
        }
    }
    
    // MARK: - Realm private functions
    
    fileprivate func getCurrentFare() -> Results<Fare> {
        let predicate = NSPredicate(format: "current == YES")
        return realm.objects(Fare.self).filter(predicate)
    }
    
    fileprivate func getFare(forName fareName: String) -> Results<Fare> {
        let predicate = NSPredicate(format: "name == %@", fareName)
        return realm.objects(Fare.self).filter(predicate)
    }
    
    fileprivate func getBusLinesForLineNumbers(_ busLines: [Int]) -> Results<BusLine> {
        let predicate = NSPredicate(format: "number IN %@", busLines)
        return realm.objects(BusLine.self).filter(predicate)
    }
}
