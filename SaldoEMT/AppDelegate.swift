//
//  AppDelegate.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 18/7/15.
//  Copyright (c) 2015 tovkal. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import RealmSwift
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Download JSON and update bus lines and fare info if needed
        Store.sharedInstance.updateFares()
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Downloading fares json")
        
        let endpoint: String = "https://s3.eu-central-1.amazonaws.com/saldo-emt/fares_es.json"
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create URL")
            return completionHandler(.failed)
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            print("Finished downloading fares json")
            
            // check for any errors
            guard error == nil else {
                print("error fetching fares")
                print(error!)
                return completionHandler(.failed)
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return completionHandler(.failed)
            }
            
            print("Downloaded file size is: \(Float(responseData.count) / 1000) KB")
            
            let realm = try! Realm()
            let json = JSON(data: responseData)
            if Store.sharedInstance.isNewUpdate(json: json, realm: realm) {
                print("New fare json update, processing...")
                Store.sharedInstance.processJSON(json: json, realm: realm)
                Store.sharedInstance.updateBalanceAfterUpdatingFares()
                NotificationCenter.default.post(name: Notification.Name(rawValue: BUS_AND_FARES_UPDATE), object: self)
                print("Done processing file")
                return completionHandler(.newData)
            } else {
                return completionHandler(.noData)
            }
        }
        
        task.resume()
    }
}
