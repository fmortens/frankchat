//
//  ChatViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 24/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation
import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate {
    
    var chat: Chat?
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let chat = chat {
            print("Chat view opened \(chat)")
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        self.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self.view,
                action: #selector(UIView.endEditing(_:))
            )
        )
        
        textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        if let chat = self.chat, let messageToSend = self.textField.text {
            
            
            FirebaseClient.addMessage(something: chat, messageToSend: messageToSend) { (success) in
                if success ?? false {
                    print("Success")
                } else {
                    print("Failure")
                }
            }
          
        }
        
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
