//
//  NSDecimalNumber.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 06/12/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation

extension NSDecimalNumber: Comparable {
    var intValueRoundDown: Int {
        let behaviour = NSDecimalNumberHandler(roundingMode: .down, scale: 0, raiseOnExactness: false,
                                               raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return self.rounding(accordingToBehavior: behaviour).intValue
    }

    var formattedStringValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current

        if self != 0.0 {
            formatter.minimumFractionDigits = 1
        } else {
            formatter.minimumFractionDigits = 0
        }

        return formatter.string(from: self)!
    }
}

public func == (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .orderedSame
}

public func < (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

// MARK: - Arithmetic Operators
public prefix func - (value: NSDecimalNumber) -> NSDecimalNumber {
    return value.multiplying(by: NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true))
}

public func + (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.adding(rhs)
}

public func - (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.subtracting(rhs)
}

public func * (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.multiplying(by: rhs)
}

public func / (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.dividing(by: rhs)
}

public func ^ (lhs: NSDecimalNumber, rhs: Int) -> NSDecimalNumber {
    return lhs.raising(toPower: rhs)
}

public func -= (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
    lhs = lhs.subtracting(rhs)
}
