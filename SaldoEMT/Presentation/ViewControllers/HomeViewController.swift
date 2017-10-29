//
//  HomeViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 18/7/15.
//  Copyright (c) 2015 tovkal. All rights reserved.
//

import UIKit
import SVProgressHUD
import GoogleMobileAds

class HomeViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var fareName: UILabel!
    @IBOutlet weak var remainingAmount: UILabel!
    @IBOutlet weak var tripsMade: UILabel!
    @IBOutlet weak var tripsRemaining: UILabel!
    @IBOutlet weak var tripButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!

    var dataManager: DataManager!
    var viewModel: HomeViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            fareName.text = viewModel.currentFareName
            tripsMade.text = "\(viewModel.tripsDone)"
            tripsRemaining.text = "\(viewModel.tripsRemaining)"
            remainingAmount.text = viewModel.balance.toDecimalString()
        }
    }

    // MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()

        initBanner()

        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.updateLabels),
                                               name: NSNotification.Name(rawValue: NotificationCenterKeys.BusAndFaresUpdate), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel = dataManager.getCurrentState()
    }

    // MARK: - Actions

    @IBAction func addTrip(_ sender: UIButton) {
        dataManager.addTrip { errorMessage in
            SVProgressHUD.showError(withStatus: errorMessage)
        }

        updateLabels()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddMoney", let vc = segue.destination as? AddMoneyViewController {
            vc.dataManager = dataManager
        } else if segue.identifier == "Fares", let nav = segue.destination as? UINavigationController,
            let vc = nav.topViewController as? FaresViewController {
            vc.dataManager = dataManager
        }
    }

    // MARK: Dev actions

    @IBAction func reset(_ sender: UIButton) {
        dataManager.reset()
        viewModel = dataManager.getCurrentState()
    }

    @IBAction func forceDownload(_ sender: UIButton) {
        dataManager.downloadNewFares(completionHandler: nil)
    }

    // MARK: - Private functions
    @objc fileprivate func updateLabels() {
        DispatchQueue.main.async {
            self.viewModel = self.dataManager.getCurrentState()
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
