//
//  FirebaseService+Test.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import XCTestDynamicOverlay

extension FirebaseService {
    static func failing() -> FirebaseService {
        FirebaseService(
            setup: XCTUnimplemented("\(FirebaseService.self).setup")
        )
    }
}
