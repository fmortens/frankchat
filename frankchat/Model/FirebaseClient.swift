//
//  FirebaseClient.swift
//  frankchat
//
//  Created by Frank Mortensen on 11/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

class FirebaseClient {
    
    class func login(
        username: String,
        password: String,
        completion: @escaping (Bool) -> Void
    ) {
        
        Auth.auth().signIn(
            withEmail: username,
            password: password
        ) { result, error in
            
            guard let authenticationResult = result else {
                completion(false)
                return
            }
            
            if let email = authenticationResult.user.email {
                // register the user with my user list in firebase
                // so we can list the active users
                
                let db = Firestore.firestore()
                let settings = db.settings
                settings.areTimestampsInSnapshotsEnabled = true
                db.settings = settings
                
                let contactsRef = db.collection("contacts")
                
                contactsRef.document(email).setData(
                    ["last_login": FieldValue.serverTimestamp()],
                    merge: true
                ) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                
                completion(true)
                
            } else {
                completion(false)
            }
        }
    }
    
    class func logout(
        completion: @escaping (Bool) -> Void
    ) {
        
        print("We want to log out")
        
        let firebaseAuth = Auth.auth()
        let db = Firestore.firestore()
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let contactsRef = db.collection("contacts")
        
        contactsRef.document(
            (firebaseAuth.currentUser?.email!)!
        ).setData(["logged_in": false], merge: true) { error in
            
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
                
                do {
                    try firebaseAuth.signOut()
                    
                    // Remove observer
                    
                    
                    completion(true)
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                    completion(false)
                }
            }
        }
        
    }
    
    class func monitorContactChanges(
        completion: @escaping (DocumentChangeType, DocumentChange) -> Void) {
        
        print("Showing Contact List")
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db
            .collection("contacts")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    completion(change.type, change)
                }
        }
        
    }
    
    
    class func setActive() {
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        
        if let authenticatedUser = Auth.auth().currentUser {
            let contactsRef = db.collection("contacts")
            
            contactsRef.document(
                authenticatedUser.email!
                ).setData(["logged_in": true], merge: true) { error in
                    
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                    }
            }
        }
        
        
    }
    
    class func setInactive() {
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        if let authenticatedUser = Auth.auth().currentUser {
            let contactsRef = db.collection("contacts")
            
            contactsRef.document(
                authenticatedUser.email!
                ).setData(["logged_in": false], merge: true) { error in
                    
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                    }
            }
        }
        
        
    }
    
    
    class func monitorChatChanges(
        completion: @escaping (DocumentChangeType, DocumentChange) -> Void) {
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db
            .collection("conversations")
            .whereField("participants", arrayContains: Auth.auth().currentUser!.email! )
                    .addSnapshotListener { querySnapshot, error in
                        guard let snapshot = querySnapshot else {
                            print("Error fetching snapshots: \(error!)")
                            return
                        }
                
                        snapshot.documentChanges.forEach { change in
                            completion(change.type, change)
                        }
                    }
        
    }
    
    class func getLatestChatMessage(documentId: String, completion: @escaping (Bool?, QuerySnapshot?) -> Void) {
        
        print("Fetch \(documentId)")
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db
            .collection("conversations").document(documentId).collection("messages").order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    completion(false, nil)
                    return
                }
                
                completion(true, snapshot)
        }
        
        
    }
    
    class func addMessage(conversation: Conversation, messageToSend: String, completion: @escaping (Bool?) -> Void) {
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        
        
        if conversation.id != nil {
//
            
            
            let conversationsRef = db.collection("conversations").document(conversation.id!)
            
            conversationsRef.collection("messages").addDocument(
                data: [
                    "content": messageToSend,
                    "sender": Auth.auth().currentUser?.email as Any,
                    "timestamp": FieldValue.serverTimestamp()
                ])
            
            // Set the "capital" field of the city 'DC'
            conversationsRef.updateData([
                "updated": FieldValue.serverTimestamp()
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            
            
        
            
            
            
        } else {
            print("New chat \(conversation) with \(messageToSend)")
        }
        
        
        
       
        
    }
    
    class func monitorMessagesChanges(
        conversationId: String,
        completion: @escaping (DocumentChangeType, DocumentChange) -> Void
    ) {
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db
            .collection("conversations").document(conversationId).collection("messages")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    completion(change.type, change)
                }
        }
        
    }
    
    class func addConversation(
        conversation: Conversation,
        completion: @escaping (String) -> Void
    ) {
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let documentRef = db.collection("conversations").addDocument(
            data: [
                "participants": conversation.participants,
                "updated": conversation.updated!
            ])
        
        completion(documentRef.documentID)
    }
}
