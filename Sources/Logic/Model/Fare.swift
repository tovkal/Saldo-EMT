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
    @objc private dynamic var _cost: String = "0.0"
    let days = RealmOptional<Int>()
    let rides = RealmOptional<Int>()
    @objc dynamic var imageUrl = ""
    @objc private dynamic var _tripCost: String = "0.0"
    @objc dynamic var displayBusLineTypeName = false

    override static func primaryKey() -> String? {
        return "id"
    }

    var cost: NSDecimalNumber {
        get {
            return NSDecimalNumber(string: _cost)
        }
        set {
            _cost = newValue.formattedStringValue
        }
    }

    var tripCost: NSDecimalNumber {
        get {
            return NSDecimalNumber(string: _tripCost)
        }
        set {
            _tripCost = newValue.formattedStringValue
        }
    }
}
