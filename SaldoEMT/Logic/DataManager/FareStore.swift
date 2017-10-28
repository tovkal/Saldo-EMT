//
//  FareStore.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 26/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import Crashlytics

class FareStore {
    let jsonParser: JsonParser

    init(jsonParser: JsonParser) {
        self.jsonParser = jsonParser

        if getAllFares().isEmpty {
            if let json = getFileData() {
                jsonParser.processJSON(json: json)
                log.debug("finished parsing file")
            }
        }
    }

    func getAllFares() -> [Fare] {
        let realm = RealmHelper.getRealm()
        return Array(realm.objects(Fare.self))
    }

    func getFare(forName fareName: String) -> [Fare] {
        let realm = RealmHelper.getRealm()
        let predicate = NSPredicate(format: "name == %@", fareName)
        return Array(realm.objects(Fare.self).filter(predicate))
    }

    func getFare(forId fareId: Int) -> [Fare] {
        let realm = RealmHelper.getRealm()
        let predicate = NSPredicate(format: "id == %d", fareId)
        return Array(realm.objects(Fare.self).filter(predicate))
    }

    private func getFileData() -> JSON? {
        if let path = Bundle.main.path(forResource: "fares_es", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                return JSON(data: data)
            } catch let error as NSError {
                log.error(error)
                Crashlytics.sharedInstance().recordError(error)
            }
        } else {
            log.error("Invalid filename/path.")
        }

        return nil
    }
}