//
//  FirebaseClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import Firebase
import XCTestDynamicOverlay
import Dependencies

struct FirebaseClient {
    var setup: () -> Void
}

extension FirebaseClient {
    
    static let live = FirebaseClient(
        setup: {
            FirebaseApp.configure()
        }
    )
    
    static var failing = FirebaseClient(
        setup: XCTUnimplemented("\(Self.self).setup")
    )

}

private enum FirebaseClientKey: DependencyKey {
    static let liveValue = FirebaseClient.live
    static let testValue = FirebaseClient.failing
}

extension DependencyValues {
    var firebaseClient: FirebaseClient {
        get { self[FirebaseClientKey.self] }
        set { self[FirebaseClientKey.self] = newValue }
    }
}
