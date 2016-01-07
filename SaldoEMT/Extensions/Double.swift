//
//  Double.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 16/1/16.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation

extension Double {
    func toDecimalString() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.minimumFractionDigits = 1
        
        return formatter.stringFromNumber(self)!
    }
}