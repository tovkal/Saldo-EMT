//
//  BusLineTableViewCell.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 11/10/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

class FareCell: UITableViewCell {
    
    @IBOutlet weak var fareName: UILabel!

    var heightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populateWithFare(fare: Fare) {
        fareName.text = fare.name
    }
}
