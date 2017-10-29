//
//  NotificationCenterMock.swift
//  SaldoEMTTests
//
//  Created by Andrés Pizá Bückmann on 29/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation
@testable import SaldoEMT

class NotificationCenterMock: NotificationCenterProtocol {
    private (set) var postCalled = false
    private (set) var notificationName: String?

    func post(name: NSNotification.Name, object: Any?) {
        postCalled = true
        self.notificationName = name.rawValue
    }
}
