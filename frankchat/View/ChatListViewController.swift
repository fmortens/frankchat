//
//  ChatListViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 11/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChatListViewController: UITableViewController {
    
    @IBOutlet weak var LogoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        print("Showing chat list")
    }
    
    @IBAction func LogoutButtonTapped(_ sender: Any) {
        
        print("We want to log out")
        
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            
            self.performSegue(withIdentifier: "UserIsLoggedOut", sender: nil)
            
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        
        
        
    }
}

