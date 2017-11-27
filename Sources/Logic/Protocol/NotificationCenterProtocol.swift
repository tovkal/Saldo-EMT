//
//  NotificationCenterProtocol.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 29/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation

protocol NotificationCenterProtocol {
    func post(name: NSNotification.Name, object: Any?)
}

extension NotificationCenter: NotificationCenterProtocol {}
