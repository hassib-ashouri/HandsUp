//
//  User.swift
//  HandsUp
//
//  Created by Yazan Arafeh on 3/8/19.
//  Copyright © 2019 Team07. All rights reserved.
//

import UIKit
import os.log

class User: NSObject, NSCoding {
    
    //MARK: Properties
    
    var email: String
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    //MARK: Types
    
    struct PropertyKey {
        static let email = "email";
    }
    
    //MARK: Initialization
    
    init?(email: String) {
        
        // The email must not be empty
        guard !email.isEmpty else {
            return nil
        }
        
        // Initialization should fail if there is no email
        if email.isEmpty  {
            return nil
        }
        
        // Initialize stored properties.
        self.email = email
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: PropertyKey.email)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The email is required. If we cannot decode a email string, the initializer should fail.
        guard let email = aDecoder.decodeObject(forKey: PropertyKey.email) as? String else {
            os_log("Unable to decode the email for a User object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(email: email)
    }
}
