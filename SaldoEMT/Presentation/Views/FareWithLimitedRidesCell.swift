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
        
        if let cost = fare.cost, let rides = fare.rides {
            costPerRide.text = (cost/rides).toDecimalString()
            totalRides.text = rides.stringValue
            totalCost.text = cost.toDecimalString()
        }
    }
}
