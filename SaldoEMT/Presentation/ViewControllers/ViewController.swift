//
//  ViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 18/7/15.
//  Copyright (c) 2015 tovkal. All rights reserved.
//

import UIKit
import SVProgressHUD
import GoogleMobileAds

class ViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var fareName: UILabel!
    @IBOutlet weak var remainingAmount: UILabel!
    @IBOutlet weak var tripsMade: UILabel!
    @IBOutlet weak var tripsRemaining: UILabel!
    @IBOutlet weak var tripButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!

    // MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()

        initBanner()

        Store.sharedInstance.initFare()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateLabels), name: NSNotification.Name(rawValue: NotificationCenterKeys.BusAndFaresUpdate), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        setupLabels()
    }

    // MARK: - Actions

    @IBAction func addTrip(_ sender: UIButton) {
        if let errorMessage = Store.sharedInstance.addTrip() {
            SVProgressHUD.showError(withStatus: errorMessage)
        }

        updateLabels()
    }

    // MARK: Dev actions

    @IBAction func reset(_ sender: UIButton) {
        Store.sharedInstance.reset()
        updateLabels()
    }

    @IBAction func forceDownload(_ sender: UIButton) {
        Store.sharedInstance.updateFares(performFetchWithCompletionHandler: nil)
    }

    // MARK: - Private functions

    fileprivate func setupLabels() {
        log.debug("Setting up labels")
        let settings = Store.sharedInstance.getSettings()

        if let currentFareName = settings.currentFare?.name {
            fareName.text = currentFareName
        }
        tripsMade.text = "\(settings.tripsDone)"
        tripsRemaining.text = "\(settings.tripsRemaining)"
        remainingAmount.text = settings.balance.toDecimalString()
    }

    @objc fileprivate func updateLabels() {
        DispatchQueue.main.async {
            self.setupLabels()
        }
    }

    fileprivate func initBanner() {
        bannerView.adUnitID = "ca-app-pub-0951032527002077/6731131411"
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "8c4736685495e1d2bd6b4c2c78c101d7"]
        bannerView.load(request)
    }
}
