//
//  FirebaseService+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies

extension DependencyValues {
    private enum FirebaseServiceKey: DependencyKey {
        static let liveValue = FirebaseService.live()
        static let testValue = FirebaseService()
    }
    
    public var firebaseService: FirebaseService {
        get { self[FirebaseServiceKey.self] }
        set { self[FirebaseServiceKey.self] = newValue }
    }
}
