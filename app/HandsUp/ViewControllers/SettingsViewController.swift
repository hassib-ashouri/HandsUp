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
    override func viewDidLoad() {
        super.viewDidLoad()
        currentEmail.text = UserDefaults.standard.string(forKey: "email")
        currentEmail.sizeToFit()
        saveEmailButton.layer.cornerRadius = 4
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func saveEmailButtonTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        let newEmail = newEmailTextField.text
        defaults.set(newEmail, forKey: "email")
        currentEmail.text = defaults.string(forKey: "email")
    }
}
