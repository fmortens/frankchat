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


struct Chat {
    let id: String
    let sender: String
    let receiver: String
    let updated: Timestamp
}


class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet var chatListView: UITableView!
    
    var chats = [Chat]()
    
    
    override func viewDidLoad() {
        
        chatListView.dataSource = self
        chatListView.delegate = self
            
        FirebaseClient.monitorChatChanges(completion: handleChatChanges(changeType:change:))
    }
    
    
    func handleChatChanges(changeType: DocumentChangeType, change: DocumentChange) {
        
        if (changeType == .added) {
            
            let chat = Chat(
                id: change.document.documentID,
                sender: (change.document.data()["sender"] as? String)!,
                receiver: (change.document.data()["receiver"] as? String)!,
                updated: (change.document.data()["updated"] as? Timestamp)!
            )
            
            print("Added \(chat)")
            
            self.chats.append(chat)
        }
        
        if (changeType == .modified) {
            
            let chat = Chat(
                id: change.document.documentID,
                sender: (change.document.data()["sender"] as? String)!,
                receiver: (change.document.data()["receiver"] as? String)!,
                updated: (change.document.data()["updated"] as? Timestamp)!
            )
            
            self.chats[Int(change.newIndex)] = chat
            
        }
        
        if (changeType == .removed) {
            self.chats.remove(at: Int(change.oldIndex))
        }
        
        self.chatListView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.chats.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chat = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")!
        
        cell.textLabel!.text = chat.sender
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chat = chats[indexPath.row]
        
        print("Just selected \(chat)")
        
        FirebaseClient.getLatestChatMessage(documentId: chat.id) { (success, snapshot) in
            
            guard let success = success else {
                print("FAILURE")
                return
            }
            
            if success {
                print("successful")
                
                if let snapshot = snapshot {
                    
                    for document in snapshot.documents {
                        print("document is -> \(document.data()))")
                    }
                }
            }
            
        }
        
        
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

