//
//  Fare.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import Foundation

struct Fare: Equatable {
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

func == (lhs: Fare, rhs: Fare) -> Bool {
    return lhs.name == rhs.name && lhs.cost == rhs.cost && lhs.days == rhs.days && lhs.rides == rhs.rides
}