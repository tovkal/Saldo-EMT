//
//  ViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 18/7/15.
//  Copyright (c) 2015 tovkal. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController {
    
    @IBOutlet weak var remainingAmount: UILabel!
    @IBOutlet weak var tripsMade: UILabel!
    @IBOutlet weak var tripsRemaining: UILabel!
    @IBOutlet weak var tripButton: UIButton!
    @IBOutlet weak var moneyButton: UIButton!
    @IBOutlet weak var bannerView: ADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func addTrip(sender: UIButton) {
        updateLabels()
    }
    
    @IBAction func addMoney(sender: UIButton) {
    }
    
    private func updateLabels() {
        /*remainingAmount.text = "\(viewModel.amount!) €"
        tripsMade.text = String(viewModel.tripsMade!)
        tripsRemaining.text = String(viewModel.tripsRemaining!)
        
        if let remainingTrips = viewModel.tripsRemaining where remainingTrips == 0 {
            self.tripButton.enabled = false
        }*/
    }
}

extension ViewController: ADBannerViewDelegate {
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        bannerView.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        bannerView.hidden = true
    }
}

