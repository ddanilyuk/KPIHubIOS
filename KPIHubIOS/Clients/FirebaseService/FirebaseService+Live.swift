//
//  FirebaseService+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Firebase

extension FirebaseService {
    static func live() -> FirebaseService {
        FirebaseService(
            setup: {
                FirebaseApp.configure()
            }
        )
    }
}
