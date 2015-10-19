//
//  LineViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 10/10/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

private let identifier = "FareCell"

class FaresViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var fares = [Fare]()
    private var contentViewControllers: [BusLineCollectionViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "FareCell", bundle: nil), forCellReuseIdentifier: identifier)
        tableView.estimatedRowHeight = 150;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        fares = Array(Store.sharedInstance.fares.values)
        fares.sortInPlace({ Int($0.number) < Int($1.number) })
        
        for fare in fares {
            let busLineCollectionViewController = storyboard!.instantiateViewControllerWithIdentifier("BusLineCollectionViewController") as! BusLineCollectionViewController
            busLineCollectionViewController.busLines = Store.sharedInstance.getBusLinesForFare(fare.number)
            self.addChildViewController(busLineCollectionViewController)
            contentViewControllers.append(busLineCollectionViewController)
        }
    }
    @IBAction func didCancelFareSelection(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FaresViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(150)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! FareCell
        
        cell.populateWithFare(fares[indexPath.row])
        cell.populateWithBusLines(contentViewControllers[indexPath.row])
        
        return cell
    }
}