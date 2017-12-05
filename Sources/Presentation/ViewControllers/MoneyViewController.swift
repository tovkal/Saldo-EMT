//
//  MoneyViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá Bückmann on 03/12/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import UIKit
import SVProgressHUD

class MoneyViewController: UIViewController {

    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var resetSwitch: UISwitch?
    var dataManager: DataManagerProtocol!

    @IBAction func cancelModal(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func acceptAmount(_ sender: UIButton) {
        if let input = self.input.text, let amount = input.doubleValue {
            if resetSwitch?.isOn == false {
                guard checkMinimum(amount) else { SVProgressHUD.showError(withStatus: getMinimumAmountErrorMessage()); return }
                dataManager.addMoney(amount)
            } else {
                guard amount >= 0 else { SVProgressHUD.show(withStatus: "balance.errors.initial-minimum-amount".localized); return }
                dataManager.setBalance(amount)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

    func checkMinimum(_ amount: Double) -> Bool {
        preconditionFailure("This method needs to be implemented in all sublclasses")
    }

    func getMinimumAmountErrorMessage() -> String {
        preconditionFailure("This method needs to be implemented in all sublclasses")
    }
}
