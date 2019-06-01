//
//  ConversationViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 24/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ConversationViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var conversation: Conversation?
    var messages = [Message]()
    var listener: ListenerRegistration?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        FirebaseClient.monitorMessagesChanges(
            conversationId: (conversation?.id!)!,
            completion: handleMessagesChanges,
            registerListener: handleListener
        )
        
        textField.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerNotifications()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.listener!.remove()
        unregisterNotifications()
    }
    
    func handleListener(listener: ListenerRegistration) {
        self.listener = listener
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
                
                    self.messages.insert(message, at: Int(change.newIndex))
                }
            
            case .modified:
                
                let message = Message(
                    content: change.document.data()["content"] as! String,
                    sender: change.document.data()["sender"] as! String,
                    timestamp: change.document.data()["timestamp"] as? Timestamp
                )
                
                self.messages[Int(change.oldIndex)] = message
            
            case .removed:
        
                self.messages.remove(at: Int(change.oldIndex))
        
            default:
                print("Unknown message change")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            
            // Scroll down messages list to be able to converse
            self.tableView.setContentOffset(
                CGPoint(
                    x: 0,
                    y: self.tableView.contentSize.height - self.tableView.frame.height
                ),
                animated: false
            )
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        
        if let conversation = self.conversation, let messageToSend = self.textField.text {

            FirebaseClient.addMessage(conversation: conversation, messageToSend: messageToSend) { (success) in
                if success ?? false {
                    self.textField.text = ""
                    
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
        let message = messages.sorted(by: { (message1, message2) -> Bool in
            if let timestamp1 = message1.timestamp,
                let timestamp2 = message2.timestamp {
                return timestamp1.seconds < timestamp2.seconds
            } else {
                return false
            }
        })[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")!
        
        cell.textLabel!.text = message.content
        
        return cell
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
            
            textFieldBottomConstraint.constant = -keyboardSize.height + 35
            
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .transitionCurlDown,
                animations: {
                    self.view.layoutIfNeeded()
                },
                completion: nil
            )
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
            textFieldBottomConstraint.constant = 0
            
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .transitionCurlDown,
                animations: {
                    self.view.layoutIfNeeded()
                },
                completion: nil
            )
            
            
        
    }
    
}
