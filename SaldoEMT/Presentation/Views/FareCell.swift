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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populateWithFare(fare: Fare) {
        fareName.text = fare.name
        busLines.image = UIImage(named: fare.lines.count == 2 ? few : many)
    }
}
