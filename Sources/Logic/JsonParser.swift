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
import UIKit

protocol JsonParserProtocol {
    func processJSON(json: JSON)
}

class JsonParser: NSObject, JsonParserProtocol {

    func processJSON(json: JSON) {
        let realm = RealmHelper.getRealm()

        do {
            let fares = realm.objects(Fare.self)
            try realm.write {
                realm.delete(fares)
                parseFares(realm, json)
                updateSettings(realm, json)
            }
        } catch let error as NSError {
            log.error(error)
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    private func parseFares(_ realm: Realm, _ json: JSON) {
        for (_, fare) in json["fares"] {
            for (fareNumber, fareInfo) in fare {
                storeFare(realm,
                          id: Int(fareNumber)!,
                          name: fareInfo["name"].stringValue,
                          busLineType: fareInfo["busLineType"].stringValue,
                          cost: fareInfo["cost"].doubleValue,
                          days: fareInfo["days"].int,
                          rides: fareInfo["rides"].int,
                          imageUrl: fareInfo["imageUrl"].stringValue,
                          displayBusLineTypeName: fareInfo["displayBusLineTypeName"].boolValue)
            }
        }
    }

    // swiftlint:disable:next function_parameter_count
    private func storeFare(_ realm: Realm, id: Int, name: String, busLineType: String,
                           cost: Double, days: Int?, rides: Int?, imageUrl: String, displayBusLineTypeName: Bool) {
        guard cost > 0.0 else { return }

        let fare = Fare()

        fare.id = id
        fare.name = name
        fare.busLineType = busLineType
        fare.cost = NSDecimalNumber(value: cost)
        fare.days.value = days
        fare.rides.value = rides
        fare.imageUrl = getUrlForScaleFactor(imageUrl)
        fare.displayBusLineTypeName = displayBusLineTypeName

        if let rides = fare.rides.value {
            fare.tripCost = fare.cost / NSDecimalNumber(value: rides)
        } else {
            fare.tripCost = fare.cost
        }
        // With update true objects with a primary key (BusLine has one) get updated when they already exist or inserted when not
        realm.add(fare, update: true)
    }

    private func getUrlForScaleFactor(_ url: String) -> String {
        let file = url[..<url.index(url.endIndex, offsetBy: -4)]
        let urlExtension = url[url.index(url.endIndex, offsetBy: -4)...]
        let scale = UIScreen.main.scale > 1.0 ? "@\(Int(UIScreen.main.scale))x" : ""
        return file + scale + urlExtension
    }

    private func updateSettings(_ realm: Realm, _ json: JSON) {
        guard let timestamp = json["timestamp"].int else { return }
        let settings = realm.objects(Settings.self).first ?? Settings()
        guard settings.lastTimestamp == 0 else { return }
        log.debug("Setting initial timestamp")
        settings.lastTimestamp = timestamp
        realm.add(settings, update: true)
    }
}
