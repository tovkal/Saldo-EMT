//
//  Settings.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 25/10/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation
import RealmSwift

class Settings: Object {
    @objc private dynamic var id = 0
    // Last processed fares files timestamp
    @objc dynamic var lastTimestamp = 0
    // Current selected fare
    @objc dynamic var currentFare: Fare?
    @objc private dynamic var _balance: String = "0.0" // Current balance
    @objc dynamic var tripsDone = 0 // Trips done
    @objc dynamic var tripsRemaining = 0 // Remaining trips given current balance

    override static func primaryKey() -> String? {
        return "id"
    }

    var balance: NSDecimalNumber {
        get {
            return NSDecimalNumber(string: _balance)
        }
        set {
            _balance = newValue.formattedStringValue
        }
    }
}
