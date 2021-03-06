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
                
                let contactsRef = db.collection("contacts")
                
                contactsRef.document(email).setData(
                    ["last_login": FieldValue.serverTimestamp()], // Using server timestamp here, but I might change this
                    merge: true
                ) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    }
                }
                
                setActive()
                completion(true)
                
            } else {
                setInactive()
                completion(false)
            }
        }
    }
    
    class func logout( completion: @escaping (Bool) -> Void ) {
        
        let firebaseAuth = Auth.auth()
        let db = Firestore.firestore()
        
        let contactsRef = db.collection("contacts")
        
        contactsRef.document(
            (firebaseAuth.currentUser?.email!)!
        ).setData(["logged_in": false], merge: true) { error in
            
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                
                do {
                    setInactive()
                    try firebaseAuth.signOut()
                    completion(true)
                } catch _ as NSError {
                    completion(false)
                }
            }
        }
        
    }
    
    
    class func register(
        email: String,
        password: String,
        completion: @escaping (Bool?, FirebaseError?) -> Void
    ) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if user != nil {
                completion(true, nil)
            }
            
            if error != nil {
                completion(false, FirebaseError.usernameExist)
            }
        }

    }
    
    
    class func monitorContactChanges(
        completion: @escaping (DocumentChangeType, DocumentChange) -> Void) {
        
        let db = Firestore.firestore()
        
        db
            .collection("contacts")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    // failure
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    completion(change.type, change)
                }
        }
        
    }
    
    
    class func setActive() {
        
        let db = Firestore.firestore()
        
        if let authenticatedUser = Auth.auth().currentUser {
            let contactsRef = db.collection("contacts")
            
            contactsRef.document(
                authenticatedUser.email!
                ).setData(["logged_in": true], merge: true) { error in
                    
                    if let error = error {
                        print("Error writing document: \(error)")
                    }
            }
        }
        
        
    }
    
    class func setInactive() {
        
        let db = Firestore.firestore()
        
        if let authenticatedUser = Auth.auth().currentUser {
            let contactsRef = db.collection("contacts")
            
            contactsRef.document(
                authenticatedUser.email!
                ).setData(["logged_in": false], merge: true) { error in
                    
                    if let error = error {
                        print("Error writing document: \(error)")
                    }
            }
        }
        
        
    }
    
    
    class func monitorConversationChanges(
        completion: @escaping (DocumentChangeType, DocumentChange) -> Void,
        registerListener: (ListenerRegistration) -> Void
    ) {
        
        let db = Firestore.firestore()
        
        let listener = db
            .collection("conversations")
            .whereField("participants", arrayContains: Auth.auth().currentUser!.email! )
                    .addSnapshotListener { querySnapshot, error in
                        guard let snapshot = querySnapshot else {
                            // Error fetching snapshots
                            return
                        }
                
                        snapshot.documentChanges.forEach { change in
                            completion(change.type, change)
                        }
                    }
        
        registerListener(listener)
        
    }
    
    class func addMessage(conversation: Conversation, messageToSend: String, completion: @escaping (Bool?) -> Void) {
        
        let db = Firestore.firestore()
        
        if conversation.id != nil {
            let conversationsRef = db.collection("conversations").document(conversation.id!)
            
            conversationsRef.collection("messages").addDocument(
                data: [
                    "content": messageToSend,
                    "sender": Auth.auth().currentUser?.email as Any,
                    "timestamp": Timestamp(date: Date())
                ])
            
            conversationsRef.updateData([
                "updated": FieldValue.serverTimestamp()
            ]) { err in
                if err != nil {
                    completion(false)
                } else {
                    completion(true)
                }
            }
            
        }
        
    }
    
    class func monitorMessagesChanges(
        conversationId: String,
        completion: @escaping (DocumentChangeType, DocumentChange) -> Void,
        registerListener: (ListenerRegistration) -> Void
    ) {
        
        let db = Firestore.firestore()
        
        let listener = db
            .collection("conversations").document(conversationId).collection("messages")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    // Error fetching snapshots
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    completion(change.type, change)
                }
        }
        
        registerListener(listener)
        
    }
    
    class func addConversation(
        conversation: Conversation,
        completion: @escaping (String) -> Void
    ) {
        
        let db = Firestore.firestore()
        
        let documentRef = db.collection("conversations").addDocument(
            data: [
                "participants": conversation.participants,
                "updated": conversation.updated!
            ])
        
        completion(documentRef.documentID)
    }
    
    
    class func getLatestMessageInConversation(
        id: String,
        completion: @escaping (Message?) -> Void
    ) {
        
        let db = Firestore.firestore()
        
        let documentsRef = db.collection("conversations")
            .document(id)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
        
        documentsRef.getDocuments { (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print("Could not get snapshot \(String(describing: error))")
                completion(nil)
                return
            }
            
            if querySnapshot.documents.count == 0 {
                print("\(id) No messages")
                completion(nil)
                return
            }
            
            let document = querySnapshot.documents[0]
            
            if
                let content = document.get("content"),
                let sender = document.get("sender"),
                let timestamp = document.get("timestamp") {
                
                    let message = Message(
                        content: content as! String,
                        sender: sender as! String,
                        timestamp: (timestamp as! Timestamp)
                    )
                print("\(id) message found")
                    completion(message)
            } else {
                print("Something is missing")
                completion(nil)
            }
        }
    }
}
