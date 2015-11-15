//
//  Fare.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 27/9/15.
//  Copyright © 2015 tovkal. All rights reserved.
//

import Foundation

struct FareJSON: Equatable {
    let number: String
    let name: String
    let cost: Double
    let days: Int?
    let rides: Int?
    let lines: [Int]
    
    init(number: String, name: String, cost: Double, days: Int?, rides: Int?, lines: [Int]) {
        self.number = number
        self.name = name
        self.cost = cost
        self.days = days
        self.rides = rides
        self.lines = lines
    }
}

func == (lhs: FareJSON, rhs: FareJSON) -> Bool {
    return lhs.number == rhs.number && lhs.name == rhs.name && lhs.cost == rhs.cost && lhs.days == rhs.days && lhs.rides == rhs.rides && lhs.lines == rhs.lines
}