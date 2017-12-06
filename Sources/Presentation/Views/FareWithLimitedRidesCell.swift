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

    override func populateWithFare(_ fare: Fare, completionHandler: (() -> Void)? = nil) {
        super.populateWithFare(fare, completionHandler: completionHandler)

        totalCost.text = fare.cost.formattedStringValue

        if let rides = fare.rides.value {
            costPerRide.text = (fare.cost / NSDecimalNumber(value: rides)).formattedStringValue
            totalRides.text = String(rides)
        }
    }
}
