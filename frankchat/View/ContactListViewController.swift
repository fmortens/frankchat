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
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    var contactsIDArray = [String]()
    var db: Firestore!
    
    override func viewDidLoad() {
        
        print("Showing Contact List")
        
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        
        loadData()
        
        db.collection("active_users")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    
                    if (diff.type == .added) {
                        print("New user: \(diff.document.data())")
                    }
                    
                    if (diff.type == .modified) {
                        print("Modified user: \(diff.document.data())")
                    }
                    
                    if (diff.type == .removed) {
                        print("Removed user: \(diff.document.data())")
                    }
                    
                    //self.contactsTableView.reloadData()
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contactsTableView.reloadData()
    }
    
    func loadData() {
        db.collection("active_users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    self.contactsIDArray.append(document.documentID)
                }
            }
            print(self.contactsIDArray)
            
            self.contactsTableView.reloadData()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Tableview setup \(contactsIDArray.count)")
        return contactsIDArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell")!
        let contact = contactsIDArray[indexPath.row]
        
        cell.textLabel!.text = contact
        
        print("Array is populated \(contactsIDArray)")
        
        return cell
    }
    
}
