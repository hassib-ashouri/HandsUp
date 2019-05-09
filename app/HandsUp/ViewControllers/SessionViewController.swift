//
//  JoinSessionViewController.swift
//  HandsUp
//
//  Created by Yazan Arafeh on 3/15/19.
//  Copyright © 2019 Team07. All rights reserved.
//

import UIKit
import SocketIO

class SessionViewController: UIViewController {
    
    @IBOutlet weak var sessionCodeTextField: UITextField!
    @IBOutlet weak var sessionButton: UIButton!
    @IBOutlet weak var sessionCodeLabel: UILabel!
    @IBOutlet weak var notAUserTypeButton: UIButton!
    // if a student joined a session sucessfully
    static var joined:JoinState = .noanswer
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = Connection()
        
        // Check if user is a student or professor
        if !defaults.bool(forKey: "isStudent"){ // Professor
            sessionButton.setTitle("Start New Session", for: .normal)
            sessionCodeTextField.isHidden = true
            sessionCodeLabel.text = "Click the button below to start a new class session. You will be given a unique code which you must share with your students so they can join your class session."
            self.tabBarController?.tabBar.isHidden = true
        }
        else {
            notAUserTypeButton.isHidden = true
        }
        sessionButton.layer.cornerRadius = 4
        notAUserTypeButton.layer.cornerRadius = 4
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func notAUserTypeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sessionButtonTapped(_ sender: Any) {
        if defaults.bool(forKey: "isStudent"){  // Student
            // TODO: Add code for joining session
            let jsonLoad: [String: Any] = ["code": sessionCodeTextField.text, "email": defaults.string(forKey: "email")]
            Connection.socket.emit("join",jsonLoad)
            Connection.classCode = sessionCodeTextField.text as! String
        }
        else{                                   // Professor
            // TODO: Add code for starting session
            Connection.getSocket().emit("unique", ["className": "CS 146"])
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "recordSegue"{
            if defaults.bool(forKey: "isStudent"){      // Student requesting to joining session

                if SessionViewController.joined == .joined{
                    // TODO: Add code to check if session code is valid in server
                    Connection.classCode = sessionCodeTextField.text ?? "1234"
                    print("joined to class")
                    return true
                }
                else if SessionViewController.joined == .problem
                {
                    
                    let alertController = UIAlertController(
                        title: "Invalid Session Code",
                        message: "Session code does not exist",
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alertController, animated: true, completion: nil)
                    return false
                }
            }
            else{       // Professor requesting unique session code
                // TODO: Add code to wait for unique session code from server
                // waite untile we get a response
            }
        }
        return true
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

enum JoinState
{
    case joined
    case problem
    case noanswer
}
