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
    var dataManager: DataManagerProtocol!

    @IBAction func cancelModal(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func acceptAmount(_ sender: UIButton) {
        if let input = input.text, let amount = Double(input) {
            guard checkMinimum(amount) else { SVProgressHUD.showError(withStatus: getMinimumAmountErrorMessage()); return }
            dataManager.addMoney(amount)
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
