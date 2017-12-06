//
//  InitialMoneyViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 03/12/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import UIKit

class InitialMoneyViewController: MoneyViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        input.text = "0"
    }

    override func checkMinimum(_ amount: NSDecimalNumber) -> Bool {
        return amount >= 0
    }

    override func getMinimumAmountErrorMessage() -> String {
        return "balance.errors.initial-minimum-amount".localized
    }
}
