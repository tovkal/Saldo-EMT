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
    @objc dynamic var number = 0
    @objc dynamic var hexColor = ""
    @objc dynamic var name = ""

    override static func primaryKey() -> String? {
        return "number"
    }
}
