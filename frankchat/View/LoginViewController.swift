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
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        loginButton.layer.cornerRadius = 5
        statusLabel.isHidden = true
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.statusLabel.isHidden = false
        self.statusLabel.textColor = UIColor.black
        self.statusLabel.text = "Logging in..."
        
        if let username = emailTextField.text,
           let password = passwordTextField.text {
        
            FirebaseClient.login(username: username, password: password) { (successful) in
                if successful {
                    self.statusLabel.isHidden = true
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "UserLoggedIn", sender: nil)
                    }
                    
                } else {
                    self.statusLabel.isHidden = false
                    self.statusLabel.textColor = UIColor.red
                    self.statusLabel.text = "Login failed"
                }
            }
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        print("Register button pressed")
        
        self.performSegue(withIdentifier: "presentRegisterScreen", sender: nil)
        
    }
    
    
}
