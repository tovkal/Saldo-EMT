//
//  BusLine.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 16/1/16.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class BusLine: Object {
    dynamic var number = 0
    dynamic var hexColor = ""
    dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "number"
    }
}
