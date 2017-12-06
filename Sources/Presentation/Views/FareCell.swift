//
//  BusLineTableViewCell.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 11/10/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit
import Kingfisher

class FareCell: UITableViewCell {

    @IBOutlet weak var fareName: UILabel!
    @IBOutlet weak var busLines: UIImageView!
    @IBOutlet weak var costPerRide: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func populateWithFare(_ fare: Fare, completionHandler: (() -> Void)? = nil) {
        fareName.text = fare.name + (fare.displayBusLineTypeName ? " - \(fare.busLineType)" : "")
        if let url = URL(string: fare.imageUrl) {
            busLines.kf.setImage(with: url) { _, _, _, _ in
                if self.busLines.frame.height == 0 {
                    completionHandler?()
                }
            }
        }
        costPerRide.text = fare.cost.formattedStringValue
    }

    override func prepareForReuse() {
        self.busLines.kf.cancelDownloadTask()
    }
}
