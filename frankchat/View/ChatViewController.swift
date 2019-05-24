//
//  ChatViewController.swift
//  frankchat
//
//  Created by Frank Mortensen on 24/05/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation
import UIKit

class ChatViewController: UIViewController {
    
    var chat: Chat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let chat = chat {
            print("Chat view opened \(chat)")
        }
    }
    
}
