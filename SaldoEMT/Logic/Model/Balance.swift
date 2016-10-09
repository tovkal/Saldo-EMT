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
    dynamic var remaining: Double = 0.0
    dynamic var tripsDone = 0
    dynamic var tripsRemaining = 0
}