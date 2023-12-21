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
            setup: { bundle in
                let file = bundle.path(forResource: "GoogleService-Info", ofType: "plist")
                if let file, let options = FirebaseOptions(contentsOfFile: file) {
                    FirebaseApp.configure(options: options)
                } else {
                    fatalError("Can't configure firebase: \(bundle)")
                }
            }
        )
    }
}
