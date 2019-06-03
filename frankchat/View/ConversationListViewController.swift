//
//  ConversationListViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 11/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ConversationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet var chatListView: UITableView!
    
    var conversations = [Conversation]()
    var sortedConversations = [Conversation]()
    var selectedConversation: Conversation?
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        
        chatListView.dataSource = self
        chatListView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if listener == nil {
            FirebaseClient.monitorConversationChanges(
                completion: handleChatChanges,
                registerListener: handleListener
            )
        }
        
        self.sortConversations()
        
    }
    
    
    func handleListener(listener: ListenerRegistration) {
        self.listener = listener
    }
    
    
    func handleChatChanges(changeType: DocumentChangeType, change: DocumentChange) {
        
        switch changeType {
        case .added:
            let conversation = Conversation(
                id: change.document.documentID,
                participants: change.document.data()["participants"] as! [String],
                updated: change.document.data()["updated"] as? Timestamp
            )
            
            self.conversations.append(conversation)
        
        case .modified:
            let conversation = Conversation(
                id: change.document.documentID,
                participants: change.document.data()["participants"] as! [String],
                updated: change.document.data()["updated"] as? Timestamp
            )
            
            self.conversations[Int(change.oldIndex)] = conversation
            
        case .removed:
            
            self.conversations.remove(at: Int(change.oldIndex))
            
        default:
            print("Unknown modification")
        }
        
        self.sortConversations()
        
    }
    
    func sortConversations() {
        
        self.sortedConversations = self.conversations.sorted(by: { (conversation1, conversation2) -> Bool in
            if let updated1 = conversation1.updated, let updated2 = conversation2.updated {
                return updated1.seconds > updated2.seconds
            } else {
                return false
            }
        })
        
        DispatchQueue.main.async {
            self.chatListView.reloadData()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sortedConversations.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = sortedConversations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")!
        
        if let id = conversation.id {
            
            FirebaseClient.getLatestMessageInConversation(id: id, completion: { (message) in
                if let message = message {
                    
                    let senderText = NSAttributedString(
                        string: "\(message.sender) :\n",
                        attributes:[
                            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                            NSAttributedString.Key.font: UIFont(name: "Arial", size: 24.0) as Any
                        ]
                    )
                    
                    let messageText = NSAttributedString(
                        string: message.content,
                        attributes:[
                            NSAttributedString.Key.font: UIFont(name: "Arial", size: 32.0) as Any
                        ]
                    )
                    
                    let cellText = NSMutableAttributedString()
                    cellText.append(senderText)
                    cellText.append(messageText)
                    
                    cell.textLabel!.attributedText = cellText
                } else {
                    
                    let cellText = NSAttributedString(
                        string: "No content",
                        attributes:[
                            NSAttributedString.Key.font: UIFont(name: "Arial", size: 32.0) as Any
                        ]
                    )
                    
                    cell.textLabel!.attributedText = cellText
                    
                }
                
            })
            
        }
        
        let loadingText = NSAttributedString(
            string: "...",
            attributes:[
                NSAttributedString.Key.font: UIFont(name: "Arial", size: 48.0) as Any
            ]
        )
        
        cell.textLabel!.attributedText = loadingText
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedConversation = self.sortedConversations[indexPath.row]
        
        self.performSegue(withIdentifier: "PresentChatView", sender: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? ConversationViewController {
            vc.conversation = self.selectedConversation
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

