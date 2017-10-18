//
//  Balance.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 17/1/16.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation
import RealmSwift

class Balance: Object {
    @objc dynamic var current: Double = 0.0 // Current balance
    @objc dynamic var tripsDone = 0 // Trips done
    @objc dynamic var tripsRemaining = 0 // Remaining trips given current balance
}
