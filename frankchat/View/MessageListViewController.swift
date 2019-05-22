//
//  ChatListViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 11/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class MessageListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet var messageListView: UITableView!
    
    var messages = [Message]()
    
    
    override func viewDidLoad() {
        
        messageListView.dataSource = self
        messageListView.delegate = self
            
        FirebaseClient.monitorMessageChanges(completion: handleMessageChanges(changeType:change:))
    }
    
    
    func handleMessageChanges(changeType: DocumentChangeType, change: DocumentChange) {
        
        if (changeType == .added) {
            let message = Message(
                sender: (change.document.data()["sender"] as? String)!,
                receiver: (change.document.data()["receiver"] as? String)!,
                contentText: change.document.data()["content"] as? String
            )
            
            self.messages.append(message)
        }
        
        if (changeType == .modified) {
            
            let message = Message(
                sender: (change.document.data()["sender"] as? String)!,
                receiver: (change.document.data()["receiver"] as? String)!,
                contentText: change.document.data()["content"] as? String
            )
            
            self.messages[Int(change.newIndex)] = message
            
        }
        
        if (changeType == .removed) {
            self.messages.remove(at: Int(change.oldIndex))
        }
        
        self.messageListView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")!
        
        cell.textLabel!.text = message.contentText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        print("Just selected \(message)")
        
    }
    
    
    @IBAction func LogoutButtonTapped(_ sender: Any) {
        
        FirebaseClient.logout { (success) in
            if success {
                self.performSegue(withIdentifier: "UserIsLoggedOut", sender: nil)
            } else {
                print("Ups! Can't log out?")
            }
        }
    }
    
}

