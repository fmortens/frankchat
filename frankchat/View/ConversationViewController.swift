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
    var sortedMessages = [Message]()
    var listener: ListenerRegistration?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.transform = CGAffineTransform (scaleX: 1,y: -1)
        
        FirebaseClient.monitorMessagesChanges(
            conversationId: (conversation?.id!)!,
            completion: handleMessagesChanges,
            registerListener: handleListener
        )
        
        textField.delegate = self
        textField.layer.borderWidth = 2
        
        self.title = conversation!.participants.filter({ (participant) -> Bool in
            return participant != Auth.auth().currentUser!.email
        }).first!
        
        hideKeyboardWhenTappedAround()
        
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
    }
    
    private func unregisterNotifications() {
        // Remove all observers
        NotificationCenter.default.removeObserver(self)
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
                    
                    DispatchQueue.main.async {
                    self.sortedMessages = self.messages.sorted(by: { (message1, message2) -> Bool in
                        if
                            let timestamp1 = message1.timestamp,
                            let timestamp2 = message2.timestamp {
                            
                            return timestamp1.seconds > timestamp2.seconds
                            
                        } else {
                            return false
                        }
                    })
                    }
                }
            
            case .modified:
                
                let message = Message(
                    content: change.document.data()["content"] as! String,
                    sender: change.document.data()["sender"] as! String,
                    timestamp: change.document.data()["timestamp"] as? Timestamp
                )
                
                self.messages[Int(change.oldIndex)] = message
                
                DispatchQueue.main.async {
                self.sortedMessages = self.messages.sorted(by: { (message1, message2) -> Bool in
                    if
                        let timestamp1 = message1.timestamp,
                        let timestamp2 = message2.timestamp {
                        
                        return timestamp1.seconds > timestamp2.seconds
                        
                    } else {
                        return false
                    }
                })
            }
            
            case .removed:
        
                self.messages.remove(at: Int(change.oldIndex))
                
                DispatchQueue.main.async {
                self.sortedMessages = self.messages.sorted(by: { (message1, message2) -> Bool in
                    if
                        let timestamp1 = message1.timestamp,
                        let timestamp2 = message2.timestamp {
                        
                        return timestamp1.seconds > timestamp2.seconds
                        
                    } else {
                        return false
                    }
                })
            }
        
            default:
                print("Unknown message change")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
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
        
        let message = sortedMessages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        cell.textLabel!.text = "\(dateFormatter.string(from: message.timestamp?.dateValue() ?? Date()) )\n\(message.sender):\n\(message.content)"
        cell.contentView.transform = CGAffineTransform (scaleX: 1, y: -1)
        
        return cell
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let keyboardFrame: CGRect = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
        textFieldBottomConstraint.constant = -keyboardFrame.height + view.safeAreaInsets.bottom
            
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
