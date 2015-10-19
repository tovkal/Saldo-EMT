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

class Store {
    static let sharedInstance = Store()
    
    private var jsonData: NSData?
    private(set) var busLines = [String: BusLine]()
    private(set) var fares = [String: Fare]()
    
    // MARK: - Public
    
    func getBusLinesForFare(fare: String) -> [BusLine] {
        if let fare = fares[fare] {
            
            var lines = [BusLine]()
            
            for line in fare.lines {
                if let busLine = busLines["\(line)"] {
                    lines.append(busLine)
                }
            }
            
            return lines
        } else {
            return [BusLine]()
        }
    }
    
    func getSelectedFare() -> String {
        return "1"
    }
    
    // MARK: - Init
    
    private init() {
        jsonData = getFileData()
        busLines = initBusLines()
        fares = initFares()
    }
    
    private func initBusLines() -> [String: BusLine] {
        var busLines = [String: BusLine]()
        
        if let json = jsonData {
            busLines = getBusLinesFromJson(JSON(data: json))
        }
        
        return busLines
    }
    
    private func initFares() -> [String: Fare] {
        var fares = [String: Fare]()
        
        if let json = jsonData {
            fares = getFaresFromJson(JSON(data: json))
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
    
    private func getBusLinesFromJson(json: JSON) -> [String: BusLine] {
        
        var lines = [String: BusLine]()
        
        for (_, line) in json["lines"] {
            for (lineNumber, lineInfo) in line {
                lines.updateValue(BusLine(number: lineNumber, color: UIColor(rgba: "#" + lineInfo["color"].stringValue), name: lineInfo["name"].stringValue), forKey: lineNumber)
            }
        }
        
        return lines
    }
    
    private func getFaresFromJson(json: JSON) -> [String: Fare] {
        
        var fares = [String: Fare]()
        
        for (_, fare) in json["fares"] {
            for (fareNumber, fareInfo) in fare {
                fares.updateValue(Fare(number: fareNumber, name: fareInfo["name"].stringValue, cost: fareInfo["price"].doubleValue, days: fareInfo["days"].intValue, rides: fareInfo["rides"].intValue, lines: fareInfo["lines"].arrayObject as! [Int]), forKey: fareNumber)
            }
        }
        
        return fares
    }
}
