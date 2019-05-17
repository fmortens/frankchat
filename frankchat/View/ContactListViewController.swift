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
    
    @IBOutlet weak var NewChatButton: UIBarButtonItem!
    @IBOutlet weak var contactsTableView: UITableView!
    
    var activeUsers = [ActiveUser]()
    var db: Firestore!
    
    override func viewDidLoad() {
        
        print("Showing Contact List")
        
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        
        db.collection("active_users")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    
                    if (diff.type == .added) {
                        let activeUser = ActiveUser(
                            email: diff.document.documentID,
                            username: diff.document.data()["username"] as? String,
                            loggedIn: (diff.document.data()["logged_in"] as? Bool)!
                        )
                        
                        self.activeUsers.append(activeUser)
                    }
                    
                    if (diff.type == .modified) {
                        let activeUser = ActiveUser(
                            email: diff.document.documentID,
                            username: diff.document.data()["username"] as? String,
                            loggedIn: (diff.document.data()["logged_in"] as? Bool)!
                        )
                        
                        self.activeUsers[Int(diff.newIndex)] = activeUser
                    }
                    
                    if (diff.type == .removed) {
                        self.activeUsers.remove(at: Int(diff.oldIndex))
                    }
                    
                }
                
                self.contactsTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contactsTableView.reloadData()
    }
    
    func loadData() {
        db.collection("active_users").getDocuments() { (querySnapshot, error) in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            for document in snapshot.documents {
                let data = document.data()
                
                let activeUser = ActiveUser(
                    email: document.documentID,
                    username: data["username"] as? String,
                    loggedIn: (data["logged_in"] as? Bool)!
                )
                    
                self.activeUsers.append(activeUser)
            }
            
            self.contactsTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return activeUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell")!
        let activeUser = activeUsers[indexPath.row]
        
        if let username = activeUser.username {
            cell.textLabel!.text = username
        } else {
            cell.textLabel!.text = activeUser.email
        }
        
        let firebaseAuth = Auth.auth()
        if firebaseAuth.currentUser?.email == activeUser.email {
            
            cell.textLabel?.font = UIFont(
                descriptor: UIFontDescriptor().withSymbolicTraits([.traitBold])!,
                size: 17
            )
            
        }
        
        if !activeUser.loggedIn {
            
            cell.textLabel?.textColor = UIColor.red
            cell.textLabel?.font = UIFont(
                descriptor: UIFontDescriptor().withSymbolicTraits([.traitItalic])!,
                size: 17
            )
            
        } else {
            
            cell.textLabel?.textColor = UIColor.green
            cell.textLabel?.font = UIFont(
                descriptor: UIFontDescriptor().withSymbolicTraits([.traitBold])!,
                size: 17
            )
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = activeUsers[indexPath.row]
        
        
            
            print("Just selected \(user)")
            
        
        
    }
    
    @IBAction func NewChatButtonTapped(_ sender: Any) {
        
        
        if let selectedIndexPath = contactsTableView.indexPathForSelectedRow {
            
            let user = activeUsers[selectedIndexPath.row]
            
            print("Create new chat please, with \(user)")
            
            self.contactsTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        
        
        
    }
    
}
