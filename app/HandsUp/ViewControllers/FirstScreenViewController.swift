//
//  FirstScreenViewController.swift
//  HandsUp
//
//  Copyright © 2019 Team07. All rights reserved.
//

import UIKit

class FirstScreenViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var studentButton: UIButton!
    @IBOutlet weak var professorButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentButton.layer.cornerRadius = 4
        professorButton.layer.cornerRadius = 4
    }
    
    @IBAction func studentButtonTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        let isStudent = true
        
        defaults.set(isStudent, forKey: "isStudent")
    }
    
    @IBAction func professorButtonTapped(_ sender: Any) {
        let defaults = UserDefaults.standard
        let isStudent = false
        
        defaults.set(isStudent, forKey: "isStudent")
    }
}
