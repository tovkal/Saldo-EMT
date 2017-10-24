//
//  FareStore.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 26/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation
import RealmSwift

class FareStore {
    
    fileprivate let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func getAllFares() -> [Fare] {
        return Array(realm.objects(Fare.self))
    }
    
    func getFare(forName fareName: String) -> [Fare] {
        let predicate = NSPredicate(format: "name == %@", fareName)
        return Array(realm.objects(Fare.self).filter(predicate))
    }
    
    func getFare(forId fareId: Int) -> [Fare] {
        let predicate = NSPredicate(format: "id == %d", fareId)
        return Array(realm.objects(Fare.self).filter(predicate))
    }
}
