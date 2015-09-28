//
//  Fare.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import Foundation

struct Fare {
    let name: String
    let cost: Double
    let days: Int?
    let rides: Int?
    
    init(name: String, cost: Double, days: Int?, rides: Int?) {
        self.name = name
        self.cost = cost
        self.days = days
        self.rides = rides
    }
}