//
//  FirebaseClient.swift
//  frankchat
//
//  Created by Frank Mortensen on 11/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation
import FirebaseAuth

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
                // do something with the result
                print("Logged in: \(email)")
            }
            
            completion(true)
            
        }
        
    }
    
}
