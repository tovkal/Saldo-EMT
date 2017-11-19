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
    @objc dynamic var id = -1
    @objc dynamic var name = ""
    @objc dynamic var busLineType = ""
    @objc dynamic var cost: Double = 0.0
    let days = RealmOptional<Int>()
    let rides = RealmOptional<Int>()
    @objc dynamic var imageUrl = ""
    @objc dynamic var tripCost: Double = 0.0
    @objc dynamic var displayBusLineTypeName = false

    override static func primaryKey() -> String? {
        return "id"
    }
}
