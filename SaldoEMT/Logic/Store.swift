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
    private var currentFare: FareJSON?
    
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
        return "1"
    }
    
    func getCurrentFare() -> FareJSON? {
        return currentFare
        
        // TODO: Load from CoreData
    }
    
    func setNewCurrentFare(fare: FareJSON) {
        currentFare = fare
        
        // TODO: Save in CoreData
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
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Fare", inManagedObjectContext:managedContext)
        
        for fareJSON in fares {
            let fare = Fare(entity: entity!, insertIntoManagedObjectContext: managedContext)

            fare.setValue(fareJSON.1.name, forKey: "name")
            fare.setValue(fareJSON.1.number, forKey: "number")
            fare.setValue(fareJSON.1.rides, forKey: "rides")
            fare.setValue(fareJSON.1.cost, forKey: "cost")
            fare.setValue(fareJSON.1.days, forKey: "days")
            fare.setValue(fareJSON.1.lines, forKey: "lines")
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
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
}
