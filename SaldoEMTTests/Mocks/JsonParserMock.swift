//
//  JsonParserMock.swift
//  SaldoEMTTests
//
//  Created by Andrés Pizá Bückmann on 29/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation
@testable import SaldoEMT
import SwiftyJSON

class JsonParserMock: JsonParserProtocol {
    private (set) var processJSONCalled = false

    func processJSON(json: JSON) {
        processJSONCalled = true
    }
}
