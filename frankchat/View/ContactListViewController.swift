//
//  ContactListViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 12/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import Firebase

struct ActiveUser {
    let username: String
}


class ContactListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        
        //loadData()
        
        db.collection("active_users")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    
                    if (diff.type == .added) {
                        let activeUser = ActiveUser(username: diff.document.data()["username"] as! String)
                        
                        self.activeUsers.append(activeUser)
                    }
                    
                    if (diff.type == .modified) {
                        let activeUser = ActiveUser(username: diff.document.data()["username"] as! String)
                        
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
                let activeUser = ActiveUser(username: data["username"] as! String)
                    
                self.activeUsers.append(activeUser)
            }
            
            self.contactsTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Tableview setup \(activeUsers.count)")
        return activeUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell")!
        let activeUser = activeUsers[indexPath.row]
        
        cell.textLabel!.text = activeUser.username
        
        print("Array is populated \(activeUsers)")
        
        return cell
    }
    
}
