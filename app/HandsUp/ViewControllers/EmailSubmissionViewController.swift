//
//  EmailSubmissionViewController.swift
//  HandsUp
//
//  Copyright © 2019 Team07. All rights reserved.
//

import UIKit

class EmailSubmissionViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitEmailButton: UIButton!
    @IBOutlet weak var notAStudentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitEmailButton.layer.cornerRadius = 4
        notAStudentButton.layer.cornerRadius = 4
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func saveEmailButtonTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        let email = emailTextField.text
        
        defaults.set(email, forKey: "email")
        defaults.set(true, forKey: "isFirstLaunch")
    }
    
    @IBAction func notAStudentButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
