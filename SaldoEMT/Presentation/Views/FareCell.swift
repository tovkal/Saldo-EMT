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
    @IBOutlet weak var busLinesView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        busLinesView = nil
    }
    
    func populateWithBusLines(busLinesVC: BusLineCollectionViewController) {
        if busLinesVC.view != nil && busLinesView != nil {
            busLinesView.addSubview(busLinesVC.view)
        }
    }
}
