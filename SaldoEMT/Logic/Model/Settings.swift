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
    // Last processed fares files timestamp
    @objc dynamic var lastTimestamp = 0
    // Current selected fare
    @objc dynamic var currentFare = -1
}
