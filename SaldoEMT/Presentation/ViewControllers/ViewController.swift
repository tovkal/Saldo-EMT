//
//  ViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 18/7/15.
//  Copyright (c) 2015 tovkal. All rights reserved.
//

import UIKit
import iAd
import SVProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var fareName: UILabel!
    @IBOutlet weak var remainingAmount: UILabel!
    @IBOutlet weak var tripsMade: UILabel!
    @IBOutlet weak var tripsRemaining: UILabel!
    @IBOutlet weak var tripButton: UIButton!
    @IBOutlet weak var bannerView: ADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        updateLabels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addTrip(sender: UIButton) {        
        if let errorMessage = Store.sharedInstance.addTrip() {
            SVProgressHUD.showErrorWithStatus(errorMessage)
        }
                
        updateLabels()
    }
    
    @IBAction func addMoney(sender: UIButton) {
    }
    
    private func updateLabels() {
        fareName.text = Store.sharedInstance.getSelectedFare()
        tripsMade.text = "\(Store.sharedInstance.getTripsDone())"
        tripsRemaining.text = "\(Store.sharedInstance.getTripsRemaining())"
        remainingAmount.text = Store.sharedInstance.getRemainingBalance().toDecimalString()
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

