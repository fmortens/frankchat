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
    
    class func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        
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
                
                let usersRef = db.collection("active_users")
                usersRef.document(email).setData( ["username": "", "lastLogin": FieldValue.serverTimestamp()], merge: true) { error in
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
    
}
