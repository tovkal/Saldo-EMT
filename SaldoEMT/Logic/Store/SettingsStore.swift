//
//  SettingsStore.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 26/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import SwiftyJSON
import RealmSwift

class SettingsStore {
    
    func initSettings(in realm: Realm) {
        let settings = Settings()
        
        try! realm.write {
            realm.add(settings)
        }
    }
    
    func isNewUpdate(json: JSON, realm: Realm) -> Bool {
        let settings = realm.objects(Settings.self).first!
        let timestamp = json["timestamp"].intValue
        
        log.debug("settings timestamp < downloaded timestamp: \(settings.lastTimestamp) < \(timestamp)")
        
        // Settins.lastTimestamp is 0 when a fares json file has never been processed
        return settings.lastTimestamp == 0 || settings.lastTimestamp < timestamp
    }
}
