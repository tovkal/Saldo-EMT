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
    dynamic var cost = 0.0
    let days = RealmOptional<Int>()
    let lines = List<BusLine>()
    dynamic var name = ""
    dynamic var number = ""
    let rides = RealmOptional<Int>()
    dynamic var current = false
    
    override static func primaryKey() -> String? {
        return "number"
    }
}
