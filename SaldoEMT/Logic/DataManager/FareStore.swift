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
    func getAllFares() -> [Fare]
    func getFare(forName fareName: String) -> [Fare]
    func getFare(forId fareId: Int) -> [Fare]
}

class FareStore: FareStoreProtocol {

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
}
