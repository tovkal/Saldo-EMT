//
//  String.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 05/12/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation

extension String {
    static let numberFormatter = NumberFormatter()

    var doubleValue: Double? {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return nil
    }

    var decimalNumber: NSDecimalNumber {
        return NSDecimalNumber(string: self.replacingOccurrences(of: ",", with: "."))
    }
}
