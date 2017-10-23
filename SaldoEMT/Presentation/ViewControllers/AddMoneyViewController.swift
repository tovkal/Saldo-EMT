//
//  AddMoneyViewController.swift
//  SaldoEMT
//
//  Created by Andrés Pizá on 30/7/15.
//  Copyright (c) 2015 tovkal. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddMoneyViewController: UIViewController {
    
    @IBOutlet weak var input: UITextField!
    
    @IBAction func cancelModal(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptAmount(_ sender: UIButton) {
        if let input = input.text, let amount = Double(input) {
            
            guard amount >= 5 else { SVProgressHUD.showError(withStatus: "A minimum of 5 € is required"); return }
            
            Store.sharedInstance.addMoney(amount)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
