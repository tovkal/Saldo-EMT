//
//  LineViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 10/10/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit
import CoreData

private let fareIdentifier = "FareCell"
private let fareWithRidesIdentifier = "FareWithLimitedRidesCell"
private let fareWithUnlimitedRidesIdentifier = "FareWithUnlimitedRidesCell"

class FaresViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var fares = [Fare]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "FareCell", bundle: nil), forCellReuseIdentifier: fareIdentifier)
        tableView.registerNib(UINib(nibName: "FareWithLimitedRidesCell", bundle: nil), forCellReuseIdentifier: fareWithRidesIdentifier)
        tableView.registerNib(UINib(nibName: "FareWithUnlimitedRidesCell", bundle: nil), forCellReuseIdentifier: fareWithUnlimitedRidesIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200.0
    }
    
    override func viewWillAppear(animated: Bool) {
        fares = Store.sharedInstance.getAllFares()
    }
    
    @IBAction func didCancelFareSelection(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FaresViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fares.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let fare = fares[indexPath.row]
        
        if fare.rides == nil && fare.days == nil {
            let cell = tableView.dequeueReusableCellWithIdentifier(fareIdentifier, forIndexPath: indexPath) as! FareCell
            
            cell.populateWithFare(fare)
            
            return cell
        } else if fare.rides == nil && fare.days != nil {
            let cell = tableView.dequeueReusableCellWithIdentifier(fareWithUnlimitedRidesIdentifier, forIndexPath: indexPath) as! FareWithUnlimitedRidesCell
            
            cell.populateWithFare(fare)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(fareWithRidesIdentifier, forIndexPath: indexPath) as! FareWithLimitedRidesCell
            
            cell.populateWithFare(fare)
            
            return cell
        }
    }
}

extension FaresViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(), {
            Store.sharedInstance.setNewCurrentFare(self.fares[indexPath.row])
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}