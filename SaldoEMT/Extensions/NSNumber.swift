//
//  NSNumber.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 10/1/16.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation

extension NSNumber {
    
    func toDecimalString() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.minimumFractionDigits = 1
        
        return formatter.stringFromNumber(self)!
    }
}

public func /(lhs: NSNumber, rhs: NSNumber) -> NSNumber {
    return (lhs.doubleValue / rhs.doubleValue) as NSNumber
}
