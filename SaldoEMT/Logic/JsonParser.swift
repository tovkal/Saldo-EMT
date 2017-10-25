//
//  JsonParser.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 24/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import Crashlytics

class JsonParser: NSObject {
    let realm = RealmHelper.getRealm()

    func processJSON(json: JSON) {
        parseBusLines(json)
        parseFares(json)
    }

    func parseBusLines(_ json: JSON) {
        for (_, line) in json["lines"] {
            for (lineNumber, lineInfo) in line {
                let busLine = BusLine()
                busLine.number = Int(lineNumber)!
                busLine.hexColor = lineInfo["color"].stringValue
                busLine.name = lineInfo["name"].stringValue

                do {
                    try realm.write {
                        realm.add(busLine, update: true)
                    }
                } catch let error as NSError {
                    log.error(error)
                    Crashlytics.sharedInstance().recordError(error)
                }
            }
        }
    }

    func parseFares(_ json: JSON) {
        for (_, fare) in json["fares"] {
            for (fareNumber, fareInfo) in fare {
                storeFare(id: Int(fareNumber)!, name: fareInfo["name"].stringValue, rides: fareInfo["rides"].int,
                          price: fareInfo["price"].doubleValue, days: fareInfo["days"].int,
                          busLines: getBusLinesForLineNumbers(fareInfo["lines"].arrayObject as? [Int]))
            }
        }
    }

    func storeFare(id: Int, name: String, rides: Int?, price: Double, days: Int?, busLines: [BusLine]) {
        let fare = Fare()

        fare.name = name
        fare.id = id
        fare.rides.value = rides
        fare.cost = price
        fare.days.value = days
        for busLine in busLines {
            fare.lines.append(busLine)
        }

        if let rides = fare.rides.value {
            fare.tripCost = fare.cost / Double(rides)
        } else {
            fare.tripCost = fare.cost
        }

        do {
            try realm.write {
                // With update true objects with a primary key (BusLine has one) get updated when they already exist or inserted when not
                realm.add(fare, update: true)
            }
        } catch let error as NSError {
            log.error(error)
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    fileprivate func getBusLinesForLineNumbers(_ busLines: [Int]?) -> [BusLine] {
        guard let busLines = busLines else { fatalError("A Fare must have at least one BusLine") }
        let predicate = NSPredicate(format: "number IN %@", busLines)
        return Array(realm.objects(BusLine.self).filter(predicate))
    }
}
