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

protocol JsonParserProtocol {
    func processJSON(json: JSON)
}

class JsonParser: NSObject, JsonParserProtocol {
    let realm = RealmHelper.getRealm()

    func processJSON(json: JSON) {
        parseFares(json)
    }

    private func parseFares(_ json: JSON) {
        for (_, fare) in json["fares"] {
            for (fareNumber, fareInfo) in fare {
                storeFare(id: Int(fareNumber)!,
                          name: fareInfo["name"].stringValue,
                          busLineType: fareInfo["busLineType"].stringValue,
                          cost: fareInfo["cost"].doubleValue,
                          days: fareInfo["days"].int,
                          rides: fareInfo["rides"].int,
                          imageUrl: fareInfo["imageUrl"].stringValue)
            }
        }
    }

    // swiftlint:disable:next function_parameter_count
    private func storeFare(id: Int, name: String, busLineType: String, cost: Double, days: Int?, rides: Int?, imageUrl: String) {
        let fare = Fare()

        fare.id = id
        fare.name = name
        fare.busLineType = busLineType
        fare.cost = cost
        fare.days.value = days
        fare.rides.value = rides
        fare.imageUrl = imageUrl

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
}
