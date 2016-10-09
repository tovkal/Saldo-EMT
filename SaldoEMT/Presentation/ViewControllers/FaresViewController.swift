//
//  LineViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 10/10/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit
import RealmSwift

private let fareIdentifier = "FareCell"
private let fareWithRidesIdentifier = "FareWithLimitedRidesCell"
private let fareWithUnlimitedRidesIdentifier = "FareWithUnlimitedRidesCell"

class FaresViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var fares: Results<Fare> = Store.sharedInstance.getAllFares()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "FareCell", bundle: nil), forCellReuseIdentifier: fareIdentifier)
        tableView.register(UINib(nibName: "FareWithLimitedRidesCell", bundle: nil), forCellReuseIdentifier: fareWithRidesIdentifier)
        tableView.register(UINib(nibName: "FareWithUnlimitedRidesCell", bundle: nil), forCellReuseIdentifier: fareWithUnlimitedRidesIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fares = Store.sharedInstance.getAllFares()
    }
    
    @IBAction func didCancelFareSelection(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FaresViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fares.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fare = fares[(indexPath as NSIndexPath).row]
        
        if fare.rides.value == nil && fare.days.value == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: fareIdentifier, for: indexPath) as! FareCell
            
            cell.populateWithFare(fare)
            
            return cell
        } else if fare.rides.value == nil && fare.days.value != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: fareWithUnlimitedRidesIdentifier, for: indexPath) as! FareWithUnlimitedRidesCell
            
            cell.populateWithFare(fare)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: fareWithRidesIdentifier, for: indexPath) as! FareWithLimitedRidesCell
            
            cell.populateWithFare(fare)
            
            return cell
        }
    }
}

extension FaresViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            Store.sharedInstance.setNewCurrentFare(self.fares[(indexPath as NSIndexPath).row])
            print("Selected fare: \(self.fares[(indexPath as NSIndexPath).row].name)")
            self.dismiss(animated: true, completion: nil)
        })
    }
}
