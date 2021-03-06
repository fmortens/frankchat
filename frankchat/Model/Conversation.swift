//
//  Chat.swift
//  frankchat
//
//  Created by Frank Mortensen on 25/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation
import Firebase // Need this for the Timestamp data type

struct Conversation {
    
    var id: String?
    let participants: [String]
    let updated: Timestamp?
    
}
