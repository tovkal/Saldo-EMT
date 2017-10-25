//
//  RealmHelper.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 25/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation
import RealmSwift
import Crashlytics

struct RealmHelper {
    static func getRealm() -> Realm {
        do {
            return try Realm()
        } catch let error as NSError {
            log.error(error)
            Crashlytics.sharedInstance().recordError(error)
        }
        fatalError("Could not get Realm instance")
    }
}
