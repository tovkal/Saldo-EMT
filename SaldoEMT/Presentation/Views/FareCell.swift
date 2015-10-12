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
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        busLinesView = nil
    }
}

