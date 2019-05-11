//
//  ViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 11/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Showing login screen")
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if let username = emailTextField.text,
           let password = passwordTextField.text {
        
            FirebaseClient.login(username: username, password: password) { (successful) in
                if successful {
                    print("Login successful")
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "UserLoggedIn", sender: nil)
                    }
                    
                    
                } else {
                    print("Login failure")
                }
            }
        }
    }
    
}
