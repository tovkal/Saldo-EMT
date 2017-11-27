//
//  RealmMigrator.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 19/11/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMigrator {
    static func migrate(_ migration: RealmSwift.Migration, _ oldSchemaVersion: UInt64) {
        if oldSchemaVersion < 3 {
            migration.enumerateObjects(ofType: Fare.className()) { _, new in
                new?["displayBusLineTypeName"] = false
            }
        }
    }
}
