//
//  SettingsStore.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 26/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import RealmSwift

class SettingsStore {
    
    fileprivate let realm: Realm
    fileprivate let settings: Settings
    
    init(realm: Realm) {
        self.realm = realm
        
        if realm.isEmpty {
            self.settings = Settings()
            
            try! realm.write {
                realm.add(settings)
            }
        } else {
            settings = realm.objects(Settings.self).first!
        }
    }
    
    func getSettings() -> Settings {
        return settings
    }
    
    func isNewUpdate(timestamp: Int) -> Bool {
        log.debug("settings timestamp < downloaded timestamp: \(self.settings.lastTimestamp) < \(timestamp)")
        
        // Settins.lastTimestamp is 0 when a fares json file has never been processed
        return settings.lastTimestamp == 0 || settings.lastTimestamp < timestamp
    }
}
