//
//  EmailSubmissionViewController.swift
//  HandsUp
//
//  Created by Yazan Arafeh on 4/18/19.
//  Copyright © 2019 Team07. All rights reserved.
//

import UIKit

class EmailSubmissionViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitEmailButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        submitEmailButton.layer.cornerRadius = 4
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
