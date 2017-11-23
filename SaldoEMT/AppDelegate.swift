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
import AWSCognito

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        // Initialize Google Mobile Ads SDK
        guard let applicationID = valueForSecretKey("applicationID") else {
            fatalError("Missing application id for Google Ads")
        }

        GADMobileAds.configure(withApplicationID: applicationID)

        let config = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                RealmMigrator.migrate(migration, oldSchemaVersion)
        })

        Realm.Configuration.defaultConfiguration = config

        // AWS
        guard let identityPoolId = valueForSecretKey("identityPoolId") else {
            fatalError("Missing identityPoolId for AWS")
        }
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUCentral1, identityPoolId: identityPoolId)
        let configuration = AWSServiceConfiguration(region: .EUCentral1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

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
        return DataManager(settingsStore: SettingsStore(), fareStore: FareStore(), jsonParser: JsonParser())
    }

    private func valueForSecretKey(_ key: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else { return nil }
        let plist = NSDictionary(contentsOfFile: filePath)
        return plist?.object(forKey: key) as? String
    }
}
