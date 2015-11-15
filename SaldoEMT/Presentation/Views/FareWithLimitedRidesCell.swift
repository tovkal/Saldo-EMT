//
//  FareWithLimitedRidesCell.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 5/11/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

class FareWithLimitedRidesCell: FareCell {
    
    @IBOutlet weak var totalRides: UILabel!
    @IBOutlet weak var totalCost: UILabel!
    
    override func populateWithFare(fare: Fare) {
        super.populateWithFare(fare)
        costPerRide.text = String(format:"%.1f", Double(fare.cost!)/Double(fare.rides!))
        totalRides.text = String(format:"%d", fare.rides!)
        totalCost.text = String(format:"%.1f", fare.cost!)
    }
}
