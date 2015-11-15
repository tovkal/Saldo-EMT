//
//  Fare+CoreDataProperties.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 15/11/15.
//  Copyright © 2015 tovkal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Fare {

    @NSManaged var cost: NSNumber?
    @NSManaged var days: NSNumber?
    @NSManaged var lines: NSObject?
    @NSManaged var name: String?
    @NSManaged var number: String?
    @NSManaged var rides: NSNumber?

}
