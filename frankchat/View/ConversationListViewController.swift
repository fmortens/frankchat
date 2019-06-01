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
    var conversation: Conversation?
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        
        chatListView.dataSource = self
        chatListView.delegate = self
        
        if listener == nil {
            FirebaseClient.monitorConversationChanges(
                completion: handleChatChanges,
                registerListener: handleListener
            )
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.listener!.remove()
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
            
            self.conversations.insert(conversation, at: Int(change.newIndex))
        
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
        
        DispatchQueue.main.async {
            self.chatListView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.conversations.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let conversation = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")!
        
        if let id = conversation.id {
            
            FirebaseClient.getLatestMessageInConversation(id: id, completion: { (message) in
                if let message = message {
                    cell.textLabel!.text = message.content
                    cell.detailTextLabel!.text = message.sender
                }
            })
            
        }
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.conversation = conversations[indexPath.row]
        self.performSegue(withIdentifier: "PresentChatView", sender: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? ConversationViewController {
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

