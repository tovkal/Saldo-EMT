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

protocol FareStoreProtocol {
    init(jsonParser: JsonParserProtocol)
    func getAllFares() -> [Fare]
    func getFare(forName fareName: String) -> [Fare]
    func getFare(forId fareId: Int) -> [Fare]
}

class FareStore: FareStoreProtocol {
    let jsonParser: JsonParserProtocol

    required init(jsonParser: JsonParserProtocol) {
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
        if let path = Bundle.main.path(forResource: "fares", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                return try JSON(data: data)
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
