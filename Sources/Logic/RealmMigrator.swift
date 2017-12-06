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
        switch oldSchemaVersion {
        case 2:
            migrateToVersion3(migration)
        case 3:
            migrateToVersion4(migration)
        default:
            // Pray to the gods, old and new
            return
        }
    }

    private static func migrateToVersion3(_ migration: RealmSwift.Migration) {
        migration.enumerateObjects(ofType: Fare.className()) { _, new in
            new?["displayBusLineTypeName"] = false
        }
    }

    private static func migrateToVersion4(_ migration: RealmSwift.Migration) {
        migration.enumerateObjects(ofType: Fare.className()) { old, new in
            if let cost = old?["cost"] as? Double {
                new?["_cost"] = String(format: "%.2f", cost)
            }

            if let tripCost = old?["tripCost"] as? Double {
                new?["_tripCost"] = String(format: "%.2f", tripCost)
            }
        }
        migration.enumerateObjects(ofType: Settings.className()) { old, new in
            if let balance = old?["balance"] as? Double {
                new?["_balance"] = String(format: "%.2f", balance)
            }
        }
    }
}
