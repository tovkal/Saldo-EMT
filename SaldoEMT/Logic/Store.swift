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
    
    private var jsonData: NSData?
    private(set) var busLines = [String: BusLineJSON]()
    private(set) var fares = [String: FareJSON]()
    
    // MARK: - Public
    
    func getBusLinesForFare(fare: String) -> [BusLineJSON] {
        if let fare = fares[fare] {
            
            var lines = [BusLineJSON]()
            
            for line in fare.lines {
                if let busLine = busLines["\(line)"] {
                    lines.append(busLine)
                }
            }
            
            return lines
        } else {
            return [BusLineJSON]()
        }
    }
    
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
            oldFare[0].current = false
            newFare[0].current = true
        }
    }
    
    func getAllFares() -> Results<Fare> {
        let realm = try! Realm()
        return realm.objects(Fare)
    }
    
    // MARK: - Init
    
    private init() {
        jsonData = getFileData()
        busLines = initBusLines()
        fares = initFares()
    }
    
    private func initBusLines() -> [String: BusLineJSON] {
        var busLines = [String: BusLineJSON]()
        
        if let json = jsonData {
            busLines = getBusLinesFromJson(JSON(data: json))
        }
        
        return busLines
    }
    
    private func initFares() -> [String: FareJSON] {
        var fares = [String: FareJSON]()
        
        if let json = jsonData {
            fares = getFaresFromJson(JSON(data: json))
        }
        
        var firstCurrent = true
        
        for (_, fareJSON) in fares {
            let fare = Fare()
            
            fare.name = fareJSON.name
            fare.number = fareJSON.number
            fare.rides.value = fareJSON.rides
            fare.cost = fareJSON.cost
            fare.days.value = fareJSON.days
            //fare.lines.append() = fareJSON.lines
            
            if fareJSON.name == "Residentes" && firstCurrent {
                fare.current = true
                firstCurrent = false
            }
            
            let realm = try! Realm()
            
            if realm.objectForPrimaryKey(Fare.self, key: fare.number) == nil { // Add if not exists
                try! realm.write {
                    realm.add(fare, update: false)
                }
            }
        }
        
        return fares
    }
    
    // MARK: - JSON Processing
    
    private func getFileData() -> NSData? {
        if let path = NSBundle.mainBundle().pathForResource("fares_es", ofType: "json") {
            do {
                return try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
            } catch let error as NSError {
                Crashlytics.sharedInstance().recordError(error)
            }
        } else {
            print("Invalid filename/path.")
        }
        
        return nil
    }
    
    private func getBusLinesFromJson(json: JSON) -> [String: BusLineJSON] {
        
        var lines = [String: BusLineJSON]()
        
        for (_, line) in json["lines"] {
            for (lineNumber, lineInfo) in line {
                lines.updateValue(BusLineJSON(number: lineNumber, color: UIColor(rgba: "#" + lineInfo["color"].stringValue), name: lineInfo["name"].stringValue), forKey: lineNumber)
            }
        }
        
        return lines
    }
    
    private func getFaresFromJson(json: JSON) -> [String: FareJSON] {
        
        var fares = [String: FareJSON]()
        
        for (_, fare) in json["fares"] {
            for (fareNumber, fareInfo) in fare {
                fares.updateValue(FareJSON(number: fareNumber, name: fareInfo["name"].stringValue, cost: fareInfo["price"].doubleValue, days: fareInfo["days"].int, rides: fareInfo["rides"].int, lines: fareInfo["lines"].arrayObject as! [Int]), forKey: fareNumber)
            }
        }
        
        return fares
    }
    
    // MARK: - Realm private functions
    
    private func getCurrentFare() -> Results<Fare> {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "current == YES")
        return realm.objects(Fare).filter(predicate)
    }
    
    private func getFareForName(fareName: String) -> Results<Fare> {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "name == %@", fareName)
        return realm.objects(Fare).filter(predicate)
    }
}
