//
//  RegisterViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 02/06/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        registerButton.isEnabled = false
        registerButton.layer.opacity = 0.4
        
        statusLabel.isHidden = true
        
        [emailTextField, passwordTextField].forEach({
            $0.addTarget(
                self,
                action: #selector(editingChanged),
                for: .editingChanged
            )
        })
    }

    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        
            else {
                registerButton.isEnabled = false
                registerButton.layer.opacity = 0.4
                return
        }
        
        registerButton.isEnabled = true
        registerButton.layer.opacity = 1
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            FirebaseClient.register(email: email, password: password) { (success, error) in
                
                self.statusLabel.isHidden = false
                
                guard let success = success, success == true else {
                    self.statusLabel.text = error?.description ?? "An unknown error occurred"
                    self.statusLabel.textColor = UIColor.red
                    
                    return
                }
                
                self.statusLabel.text = "Registration successful"
                self.statusLabel.textColor = UIColor.black
                
                self.emailTextField.isHidden = true
                self.passwordTextField.isHidden = true
                self.registerButton.isHidden = true
                
                self.cancelButton.setTitle("Close", for: .normal)
                
            }
        }
        
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
