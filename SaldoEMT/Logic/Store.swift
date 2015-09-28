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
    
    private init() {}
    
    func getLines() {//-> [String: BusLine] {
        // TODO Check updates
        
        if let data = getFileData() {
            return processJson(JSON(data: data))
        }
    }
    
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
    
    private func processJson(json: JSON) {//-> [String: BusLine]? {

        var lines = [BusLine]()

        for (_, line) in json["lines"] {
            for (lineNumber, lineInfo) in line {
                lines.append(BusLine(number: lineNumber, color: UIColor(rgba: "#" + lineInfo["color"].stringValue), name: lineInfo["name"].stringValue, fares: processFares(lineInfo["fares"])))
            }
        }
        
        print("hey")
    }
    
    private func processFares(fares: JSON) -> [Fare] {
        
        var processedFares = [Fare]()
        
        for (_, fare) in fares {
            processedFares.append(Fare(name: fare["name"].stringValue, cost: fare["price"].doubleValue, days: fare["days"].intValue, rides: fare["rides"].intValue))
        }
        
        return processedFares
    }
}