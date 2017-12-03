//
//  AddMoneyViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 30/7/15.
//  Copyright (c) 2015 tovkal. All rights reserved.
//

import UIKit

class AddMoneyViewController: MoneyViewController {
    override func checkMinimum(_ amount: Double) -> Bool {
        return amount >= 5
    }

    override func getMinimumAmountErrorMessage() -> String {
        return "balance.errors.minimum-amount".localized
    }
}
