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
        
        try! realm.write {
            // With update true objects with a primary key (BusLine has one) get updated when they already exist or inserted when not
            realm.add(fare, update: true)
        }
    }
}
