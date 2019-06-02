//
//  FirebaseError.swift
//  frankchat
//
//  Created by Frank Mortensen on 02/06/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation

enum FirebaseError: Error {
    case usernameExist
    case networkError
}

extension FirebaseError: LocalizedError {
    public var description: String? {
        switch self {
            case .networkError:
                return "A network error occurred"
            case .usernameExist:
                return "That username already exist, please choose another"
        }
    }
}
