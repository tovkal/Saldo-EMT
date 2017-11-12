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
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        // Initialize Google Mobile Ads SDK
        GADMobileAds.configure(withApplicationID: "ca-app-pub-0951032527002077~5254398214")

        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { _, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 1 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        let dataManager = createDataManager()

        #if DEBUG
            if "true" == ProcessInfo.processInfo.environment["-isUITest"] {
                dataManager.reset()
            }
        #else
            // Download JSON and update bus lines and fare info if needed
            dataManager.downloadNewFares(completionHandler: nil)
        #endif

        if let vc = window?.rootViewController as? HomeViewController {
            vc.dataManager = dataManager
        }

        log.debug("End didFinishLaunchingWithOptions")

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        createDataManager().downloadNewFares(completionHandler: completionHandler)
        log.debug("End background fetch")
    }

    private func createDataManager() -> DataManager {
        let jsonParser = JsonParser()
        return DataManager(settingsStore: SettingsStore(), fareStore: FareStore(jsonParser: jsonParser), jsonParser: jsonParser)
    }
}
