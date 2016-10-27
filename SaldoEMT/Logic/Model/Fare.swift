//
//  Fare.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 16/1/16.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation
import RealmSwift

class Fare: Object {
    dynamic var cost: Double = 0.0
    let days = RealmOptional<Int>()
    let lines = List<BusLine>()
    dynamic var name = ""
    dynamic var id = -1
    let rides = RealmOptional<Int>()
    dynamic var tripCost: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
