//
//  StartupViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 11/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import FirebaseAuth

class StartupViewController: UIViewController {
    
    override func viewDidLoad() {
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                self.performSegue(
                    withIdentifier: "UserIsNotLoggedIn",
                    sender: nil
                )
            }
            
        } else {
            DispatchQueue.main.async {
                self.performSegue(
                    withIdentifier: "UserIsLoggedIn",
                    sender: nil
                )
            }
        }
        
    }
    
}
