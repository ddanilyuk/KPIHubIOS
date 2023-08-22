//
//  UserDefaultsService+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    private enum UserDefaultsClientKey: TestDependencyKey {
        static let testValue: any UserDefaultsServiceProtocol = UserDefaultsService(UserDefaults(suiteName: "mock")!)
        static let liveValue: any UserDefaultsServiceProtocol = UserDefaultsService(UserDefaults.standard)
    }
    
    var userDefaultsService: UserDefaultsServiceProtocol {
        get { self[UserDefaultsClientKey.self] }
        set { self[UserDefaultsClientKey.self] = newValue }
    }
}
