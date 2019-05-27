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

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet var chatListView: UITableView!
    
    var conversations = [Conversation]()
    var conversation: Conversation?
    
    override func viewDidLoad() {
        
        chatListView.dataSource = self
        chatListView.delegate = self
            
        FirebaseClient.monitorConversationChanges(completion: handleChatChanges(changeType:change:))
    }
    
    
    func handleChatChanges(changeType: DocumentChangeType, change: DocumentChange) {
        
        if (changeType == .added) {
            
            let conversation = Conversation(
                id: change.document.documentID,
                participants: change.document.data()["participants"] as! [String],
                updated: change.document.data()["updated"] as? Timestamp
            )
            
            print("Added \(conversation)")
            
            self.conversations.insert(conversation, at: 0)
        }
        
        if (changeType == .modified) {
            
            let conversation = Conversation(
                id: change.document.documentID,
                participants: change.document.data()["participants"] as! [String],
                updated: change.document.data()["updated"] as? Timestamp
            )
            
            self.conversations[Int(change.newIndex)] = conversation
            
        }
        
        if (changeType == .removed) {
            self.conversations.remove(at: Int(change.oldIndex))
        }
        
        self.chatListView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.conversations.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let conversation = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")!
        
        cell.textLabel!.text = "From: \(conversation.participants[0])"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.conversation = conversations[indexPath.row]
        
        self.performSegue(withIdentifier: "PresentChatView", sender: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Setting the chat id if this is a ChatViewController
        if let vc = segue.destination as? ChatViewController {
            vc.conversation = self.conversation
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

