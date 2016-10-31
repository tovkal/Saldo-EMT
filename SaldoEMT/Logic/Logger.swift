//
//  Logger.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 01/11/2016.
//  Copyright © 2016 tovkal. All rights reserved.
//

import Foundation
import XCGLogger

let log: XCGLogger = {
    let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
    
    // Create a destination for the system console log (via NSLog)
    let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
    
    // Optionally set some configuration options
    #if DEBUG
        systemDestination.outputLevel = .info
    #else
        systemDestination.outputLevel = .error
    #endif
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = true
    systemDestination.showThreadName = true
    systemDestination.showLevel = true
    systemDestination.showFileName = true
    systemDestination.showLineNumber = true
    systemDestination.showDate = true
    
    // Add the destination to the logger
    log.add(destination: systemDestination)
    
    // Add basic app info, version info etc, to the start of the logs
    log.logAppDetails()
    
    return log
}()
