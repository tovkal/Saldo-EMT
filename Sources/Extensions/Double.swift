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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if self != 0.0 {
            formatter.minimumFractionDigits = 1
        } else {
            formatter.minimumFractionDigits = 0
        }

        return formatter.string(from: NSNumber(value: self))!
    }
}
