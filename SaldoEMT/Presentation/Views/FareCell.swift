//
//  BusLineTableViewCell.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 11/10/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

private let few = "FewLines"
private let many = "MuchLines"

class FareCell: UITableViewCell {

    @IBOutlet weak var fareName: UILabel!
    @IBOutlet weak var busLines: UIImageView!
    @IBOutlet weak var costPerRide: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func populateWithFare(_ fare: Fare) {
        if fare.lines.isEmpty {
            fareName.text = fare.name
            busLines.image = UIImage(named: fare.lines.count == 2 ? few : many)
            costPerRide.text = fare.cost.toDecimalString()
        }
    }
}
