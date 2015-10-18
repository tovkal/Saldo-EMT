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
    
    init(number: String, color: UIColor, name: String) {
        self.number = number
        self.color = color
        self.name = name
    }
}

func == (lhs: BusLine, rhs: BusLine) -> Bool {
    return lhs.number == rhs.number && lhs.color == rhs.color && lhs.name == rhs.name
}
