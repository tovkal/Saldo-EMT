//
//  BusLine.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

struct BusLine: Equatable {
    let number: String
    let color: UIColor
    let name: String
    let fares: [Fare]
    
    init(number: String, color: UIColor, name: String, fares: [Fare]) {
        self.number = number
        self.color = color
        self.name = name
        self.fares = fares
    }
}

func == (lhs: BusLine, rhs: BusLine) -> Bool {
    return lhs.number == rhs.number && lhs.color == rhs.color && lhs.name == rhs.name && lhs.fares == rhs.fares
}
