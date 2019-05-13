//
//  SettingsViewController.swift
//  HandsUp
//
//  Copyright © 2019 Team07. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var saveEmailButton: UIButton!
    @IBOutlet weak var currentEmail: UILabel!
    @IBOutlet weak var newEmailTextField: UITextField!
    
    // initailize with old email if it existed
    override func viewDidLoad() {
        super.viewDidLoad()
        // look for old email
        currentEmail.text = UserDefaults.standard.string(forKey: "email")
        // styling
        currentEmail.sizeToFit()
        saveEmailButton.layer.cornerRadius = 4
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    /**
        button handler for saving the inputted email to the local storage.
    */
    @IBAction func saveEmailButtonTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        let newEmail = newEmailTextField.text
        defaults.set(newEmail, forKey: "email")
        // to test if it is retreivable
        currentEmail.text = defaults.string(forKey: "email")
    }
}
