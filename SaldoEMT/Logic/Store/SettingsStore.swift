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
}
