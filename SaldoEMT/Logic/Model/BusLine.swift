//
//  BusLine.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import UIKit

struct BusLine {
    let lineNumber: String
    let lineColor: UIColor
    
    init(number: String, color: UIColor) {
        lineNumber = number
        lineColor = color
    }
}
