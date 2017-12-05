//
//  DataManager.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import Crashlytics
import Kingfisher
import AWSS3

struct DataManagerErrors {
    static let costPerTripUnknown = "data-manager.errors.costPerTripUnknown".localized
    static let insufficientBalance = "data-manager.errors.insufficientBalance".localized
    static let unknown = "data-manager.errors.unknown".localized
}

enum UpdateResult {
    case newFares
    case noUpdate
    case missingCurrentFare // Got new data but the previously selected fare does not longer exist, promt the user to select a new one
}

protocol DataManagerProtocol {
    init(settingsStore: SettingsStoreProtocol, fareStore: FareStoreProtocol, jsonParser: JsonParserProtocol, session: URLSessionProtocol, notificationCenter: NotificationCenterProtocol)
    func getAllFares() -> [Fare]
    func selectNewFare(_ fare: Fare)
    func addMoney(_ amount: Double)
    func reset()
    func downloadNewFares(completionHandler: ((UIBackgroundFetchResult) -> Void)?)
    func addTrip(_ onError: ((_ errorMessage: String) -> Void)?)
    func getCurrentState() -> HomeViewModel
    func isFirstRun() -> Bool
    func shouldChooseNewFare() -> Bool
    func setBalance(_ amount: Double)
}

class DataManager: DataManagerProtocol {
    let settingsStore: SettingsStoreProtocol
    let fareStore: FareStoreProtocol
    let jsonParser: JsonParserProtocol
    let session: URLSessionProtocol
    let notificationCenter: NotificationCenterProtocol

    // MARK: - Init

    /**
     Init Store
     
     By default bus lines and fares are extracted from a minimized json filed bundled with the app in the Assets folder.
     */
    required init(settingsStore: SettingsStoreProtocol, fareStore: FareStoreProtocol,
                  jsonParser: JsonParserProtocol, session: URLSessionProtocol = URLSession.shared,
                  notificationCenter: NotificationCenterProtocol = NotificationCenter.default) {
        self.settingsStore = settingsStore
        self.fareStore = fareStore
        self.jsonParser = jsonParser
        self.session = session
        self.notificationCenter = notificationCenter

        // On first run create database from file. On subsequent runs check if embedded file is updated
        if let json = getFileData() {
            _ = processFares(from: json, precacheImages: precacheImagesFromAssets)
        }

        // Select a default fare if none is currently selected
        _ = getSelectedFare()
    }

    // MARK: - Fare functions

    func getAllFares() -> [Fare] {
        return fareStore.getAllFares()
    }

    func selectNewFare(_ fare: Fare) {
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.chooseNewFare)
        settingsStore.selectNewFare(fare)
        updateBalanceAfterUpdatingFares()
    }

    func getSelectedFare() -> Fare {
        let selectedFare: Fare

        if let fare = settingsStore.getSelectedFare() {
            selectedFare = fare
        } else {
            // By default we use the Resident fare for Urban Zone, which should have id 1 always (yuk).
            let fare = fareStore.getAllFares().first!
            settingsStore.selectNewFare(fare)
            selectedFare = fare
        }

        return selectedFare
    }

    /**
     Update fares and bus lines.

     Downloads JSON file from AWS S3 and updates fares and bus lines in Realm.
     */
    func downloadNewFares(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        log.debug("Downloading fares json")

        let transferManager = AWSS3TransferManager.default()
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("fares_\(getLanguageCode()).json")
        guard let downloadRequest = AWSS3TransferManagerDownloadRequest() else { return }

        downloadRequest.bucket = "saldo-emt"
        downloadRequest.key = "fares_\(getLanguageCode()).json"
        downloadRequest.downloadingFileURL = downloadingFileURL

        transferManager.download(downloadRequest).continueWith(executor: AWSExecutor.default(), block: { (task: AWSTask<AnyObject>) -> Any? in
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        log.error(error)
                        Crashlytics.sharedInstance().recordError(error)
                    }
                } else {
                    log.error(error)
                    Crashlytics.sharedInstance().recordError(error)
                }
                completionHandler?(.failed)
                return nil
            }

            print(task.result!)

            guard let responseData = task.result as? Data else { completionHandler?(.failed); return nil }

            log.info("Downloaded file size is: \(Float(responseData.count) / 1000) KB")

            do {
                let json = try JSON(data: responseData)
                switch self.processFares(from: json, precacheImages: self.precacheImagesFromS3) {
                case .newFares:
                    completionHandler?(.newData)
                case .noUpdate:
                    completionHandler?(.noData)
                case .missingCurrentFare:
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.chooseNewFare)
                    completionHandler?(.newData)
                }
            } catch let error as NSError {
                log.debug("Failed parsing data")
                Crashlytics.sharedInstance().recordError(error)
                completionHandler?(.failed)
                return nil
            }

            return nil
        })
    }

    // MARK: - Settings functions

    func addTrip(_ onError: ((_ errorMessage: String) -> Void)?) {
        do {
            let cost = try getCurrentTripCost()
            try settingsStore.addTrip(withCost: cost)
        } catch DataManagerError.costPerTripUnknown {
            onError?(DataManagerErrors.costPerTripUnknown)
        } catch DataManagerError.insufficientBalance {
            onError?(DataManagerErrors.insufficientBalance)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
            onError?(DataManagerErrors.unknown)
        }
    }

    func addMoney(_ amount: Double) {
        do {
            let costPerTrip = try getCurrentTripCost()
            try settingsStore.recalculateRemainingTrips(addingToBalance: amount, withTripCost: costPerTrip)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    func getCurrentState() -> HomeViewModel {
        let fare = getSelectedFare()
        return settingsStore.getCurrentState(with: fare)
    }

    func isFirstRun() -> Bool {
        let result = UserDefaults.standard.bool(forKey: UserDefaultsKeys.firstRun)
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.firstRun)
        return result
    }

    func shouldChooseNewFare() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.chooseNewFare)
    }

    func setBalance(_ amount: Double) {
        do {
            settingsStore.setBalance(amount)
            let costPerTrip = try getCurrentTripCost()
            try settingsStore.recalculateRemainingTrips(withNewTripCost: costPerTrip)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    // MARK: Dev functions

    func reset() {
        log.debug("Fare before reset: \(self.getSelectedFare())")
        selectNewFare(fareStore.getFare(forId: 1).first!)
        log.debug("Fare after reset: \(self.getSelectedFare())")
        settingsStore.reset()
    }

    // MARK: - Private Functions

    private func getCurrentTripCost() throws -> Double {
        if let tripCost = settingsStore.getSelectedFare()?.tripCost {
            return tripCost
        }

        throw DataManagerError.costPerTripUnknown
    }

    private func updateBalanceAfterUpdatingFares() {
        do {
            let newCost = try getCurrentTripCost()

            try settingsStore.recalculateRemainingTrips(withNewTripCost: newCost)
        } catch let error as NSError {
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    private func precacheImagesFromS3() {
        let urls: [URL] = Set(getAllFares().map {$0.imageUrl}).flatMap {URL(string: $0 )}
        ImagePrefetcher(urls: urls).start()
    }

    private func getLanguageCode() -> String {
        let supportedLanguages = ["es", "ca", "en"]
        for language in Locale.preferredLanguages {
            if supportedLanguages.contains(language) {
                return language
            }
        }

        return "en"
    }

    private func getFileData() -> JSON? {
        if let path = Bundle.main.path(forResource: "fares", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                return try JSON(data: data)
            } catch let error as NSError {
                log.error(error)
                Crashlytics.sharedInstance().recordError(error)
            }
        } else {
            log.error("Invalid filename/path.")
        }

        return nil
    }

    private func processFares(from json: JSON, precacheImages: () -> Void) -> UpdateResult {
        let timestamp = json["timestamp"].intValue
        let lastTimestamp = self.settingsStore.getLastTimestamp()

        // lastTimestamp is 0 when no update has ever been received
        if lastTimestamp == 0 || lastTimestamp < timestamp {
            // Save details of selected fare
            let name = self.settingsStore.getSelectedFare()?.name
            let busLineType = self.settingsStore.getSelectedFare()?.busLineType

            self.jsonParser.processJSON(json: json)
            self.updateBalanceAfterUpdatingFares()
            self.settingsStore.updateTimestamp(timestamp)
            precacheImages()
            // Send updated fares notification
            self.notificationCenter.post(name: Notification.Name(rawValue: NotificationCenterKeys.busAndFaresUpdate), object: self)

            if let name = name, let busLineType = busLineType, let fare = self.fareStore.getFare(for: name, and: busLineType) {
                self.settingsStore.selectNewFare(fare)
            } else if lastTimestamp != 0 { // lastTimestamp = 0 on first ever app run, when the user has never selected a fare. Use default fare then (Resident)
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.chooseNewFare)
            }

            log.debug("Processed new fare data")
            return .newFares
        } else {
            log.debug("No new fares data to be processed")
            return .noUpdate
        }
    }

    private func precacheImagesFromAssets() {
        let urls = Set(getAllFares().map {$0.imageUrl})
        let images: [(String, String)] = urls.flatMap({ url in
            guard let lastSlashIndex = url.range(of: "/", options: .backwards)?.upperBound else { return nil }
            let offset = url.contains("@") ? -7 : -4 // Account for scale factor suffix, i.e. Image.png and Image@2x.png
            return (String(url[lastSlashIndex..<url.index(url.endIndex, offsetBy: offset)]), url)
        })
        for (imageName, url) in images {
            if let image = UIImage(named: imageName) {
                ImageCache.default.store(image, forKey: url)
            }
        }
    }
}
