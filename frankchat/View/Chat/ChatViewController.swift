//
//  ChatViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 24/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var conversation: Conversation?
    var messages = [Message]()
    var listener: ListenerRegistration?
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        FirebaseClient.monitorMessagesChanges(conversationId: (conversation?.id!)!, completion: handleMessagesChanges, registerListener: handleListener)
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.listener!.remove()
    }
    
    func handleListener(listener: ListenerRegistration) {
        self.listener = listener
    }
    
    func handleMessagesChanges(changeType: DocumentChangeType, change: DocumentChange) {
        
        switch changeType {
        
            case .added:
                if
                    let content = change.document.data()["content"],
                    let sender = change.document.data()["sender"],
                    let timestamp = change.document.data()["timestamp"] {
                
                    let message = Message(
                        content: content as! String,
                        sender: sender as! String,
                        timestamp: timestamp as? Timestamp
                    )
                
                    print("Added new \(message), at: \(Int(change.newIndex))")
                    self.messages.insert(message, at: Int(change.newIndex))
//                    self.messages.append(message)
                }
            
            case .modified:
                
                let message = Message(
                    content: change.document.data()["content"] as! String,
                    sender: change.document.data()["sender"] as! String,
                    timestamp: change.document.data()["timestamp"] as? Timestamp
                )
            
                print("Modified \(message), newIndex: \(Int(change.newIndex)), oldIndex: \(Int(change.oldIndex))")
            
                self.messages[Int(change.oldIndex)] = message
            
            case .removed:
        
                self.messages.remove(at: Int(change.oldIndex))
        
            default:
                print("Unknown message change")
        }
        
        self.chatTableView.reloadData()
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let conversation = self.conversation, let messageToSend = self.textField.text {
            
            
            FirebaseClient.addMessage(conversation: conversation, messageToSend: messageToSend) { (success) in
                if success ?? false {
                    print("Success")
                } else {
                    print("Failure")
                }
            }
          
        }
        
        return true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")!
        
        cell.textLabel!.text = message.content
        
        return cell
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
