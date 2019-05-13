//
//  JoinSessionViewController.swift
//  HandsUp
//
//  Copyright © 2019 Team07. All rights reserved.
//

import UIKit
import SocketIO

class SessionViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var sessionCodeTextField: UITextField!
    @IBOutlet weak var sessionButton: UIButton!
    @IBOutlet weak var sessionCodeLabel: UILabel!
    @IBOutlet weak var notAProfessorButton: UIButton!
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
            notAProfessorButton.isHidden = true
        }
        sessionButton.layer.cornerRadius = 4
        notAProfessorButton.layer.cornerRadius = 4
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func notAProfessorButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sessionButtonTapped(_ sender: Any) {
        if defaults.bool(forKey: "isStudent"){  // Student
            // Student joining session
            let jsonLoad: [String: Any] = ["code": sessionCodeTextField.text, "email": defaults.string(forKey: "email")]
            Connection.socket.emit("join",jsonLoad)
            Connection.classCode = sessionCodeTextField.text as! String
        }
        else{                                   // Professor
            // Professor starting session
            Connection.getSocket().emit("unique", ["className": "CS 146"])
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "recordSegue"{
            if defaults.bool(forKey: "isStudent"){      // Student requesting to joining session

                if SessionViewController.joined == .joined{
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
                // wait until we get a response
            }
        }
        return true
    }
}

enum JoinState
{
    case joined
    case problem
    case noanswer
}
