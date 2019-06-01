//
//  ContactListViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 12/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import Firebase

class ContactListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var newChatButton: UIBarButtonItem!
    @IBOutlet weak var contactsTableView: UITableView!
    
    var contacts = [Contact]()
    var selectedContact: Contact?
    
    override func viewDidLoad() {
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        
        newChatButton.isEnabled = false
        
        FirebaseClient.monitorContactChanges(completion: handleContactListChanges(changeType:change:))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        contactsTableView.reloadData()
    }
    
    
    func handleContactListChanges(changeType: DocumentChangeType, change: DocumentChange) {
        if (changeType == .added) {
            let contact = Contact(
                email: change.document.documentID,
                username: change.document.data()["username"] as? String,
                loggedIn: (change.document.data()["logged_in"] as? Bool)!
            )
            
            self.contacts.append(contact)
        }
        
        if (changeType == .modified) {
            let contact = Contact(
                email: change.document.documentID,
                username: change.document.data()["username"] as? String,
                loggedIn: (change.document.data()["logged_in"] as? Bool)!
            )
            
            self.contacts[Int(change.newIndex)] = contact
        }
        
        if (changeType == .removed) {
            self.contacts.remove(at: Int(change.oldIndex))
        }
        
        self.contactsTableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return contacts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell")!
        let contact = contacts[indexPath.row]
        
        if let username = contact.username {
            cell.textLabel!.text = username
        } else {
            cell.textLabel!.text = contact.email
        }
        
        let firebaseAuth = Auth.auth()
        if firebaseAuth.currentUser?.email == contact.email {
            
            cell.textLabel?.font = UIFont(
                descriptor: UIFontDescriptor().withSymbolicTraits([.traitBold])!,
                size: 24
            )
            
        }
        
        if !contact.loggedIn {
            cell.textLabel?.font = UIFont(
                descriptor: UIFontDescriptor().withSymbolicTraits([.traitItalic])!,
                size: 24
            )
        } else {
            cell.textLabel?.font = UIFont(
                descriptor: UIFontDescriptor().withSymbolicTraits([.traitBold])!,
                size: 24
            )
        }
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedContact = contacts[indexPath.row]
        self.newChatButton.isEnabled = true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Setting the chat id if this is a ChatViewController
        if  let contact = self.selectedContact {
            
            
            var conversation = Conversation(
                id: nil,
                participants: [
                    Auth.auth().currentUser!.email!,
                    contact.email
                ],
                updated: Timestamp(date: Date())
            )
            
            FirebaseClient.addConversation(conversation: conversation) { (id) in
                if let vc = segue.destination as? ConversationViewController {
                    conversation.id = id
                    vc.conversation = conversation
                }
            }
            
        }
    }
    
    
    @IBAction func NewChatButtonTapped(_ sender: Any) {
        self.newChatButton.isEnabled = false
        
        if let selectedIndexPath = contactsTableView.indexPathForSelectedRow {
            self.selectedContact = contacts[selectedIndexPath.row]
            self.performSegue(withIdentifier: "PresentChatView", sender: nil)
            self.contactsTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
}
