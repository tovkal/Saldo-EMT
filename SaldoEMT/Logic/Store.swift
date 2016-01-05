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
import CoreData

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
        if let fare = getCurrentFare()?[0] {
            return fare.name
        } else {
            return "ERROR"
        }
    }
    
    func setNewCurrentFare(fare: Fare) {
        
        if let oldFare = getCurrentFare()?[0], let newFare = getFareForName(fare.name)?[0] {
            oldFare.current = false
            newFare.current = true
                        
            saveContext()
        }
    }
    
    func getAllFares() -> [Fare] {
        
        let fetchRequest = NSFetchRequest(entityName: Fare.entityName)
        
        do {
            let results = try getManagedContext().executeFetchRequest(fetchRequest)
            return results as! [Fare]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return []
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
        
        let managedContext = getManagedContext()
        let entity =  NSEntityDescription.entityForName(Fare.entityName, inManagedObjectContext:managedContext)
        
        for fareJSON in fares {
            let fare = Fare(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            fare.setValue(fareJSON.1.name, forKey: "name")
            fare.setValue(fareJSON.1.number, forKey: "number")
            fare.setValue(fareJSON.1.rides, forKey: "rides")
            fare.setValue(fareJSON.1.cost, forKey: "cost")
            fare.setValue(fareJSON.1.days, forKey: "days")
            fare.setValue(fareJSON.1.lines, forKey: "lines")
            
            if fareJSON.1.name == "Residentes" {
                fare.setValue(true, forKey: "current")
            } else {
                fare.setValue(false, forKey: "current")
            }
            
            saveContext()
        }
        
        return fares
    }
    
    // MARK: - JSON Processing
    
    private func getFileData() -> NSData? {
        if let path = NSBundle.mainBundle().pathForResource("fares_es", ofType: "json") {
            do {
                return try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
            } catch let error as NSError {
                print(error.localizedDescription)
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
    
    // MARK: - CoreData functions
    
    private func getManagedContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    private func saveContext() {
        do {
            try getManagedContext().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    private func getCurrentFare() -> [Fare]? {
        
        let fetchRequest = NSFetchRequest(entityName: Fare.entityName)
        fetchRequest.predicate = NSPredicate(format: "current = YES")
        
        do {
            if let results = try getManagedContext().executeFetchRequest(fetchRequest) as? [Fare] where results.count == 1 {
                return results
            }
        } catch {
            // TODO log error
            print(error)
        }
        
        return nil
    }
    
    private func getFareForName(fareName: String) -> [Fare]? {
        
        let fetchRequest = NSFetchRequest(entityName: Fare.entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", fareName)
        
        do {
            if let results = try getManagedContext().executeFetchRequest(fetchRequest) as? [Fare] where results.count > 0 {
                return results
            }
        } catch {
            // TODO log error
            print(error)
        }
        
        return nil
    }
}
