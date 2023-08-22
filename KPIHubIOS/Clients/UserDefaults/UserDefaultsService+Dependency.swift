//
//  UserDefaultsService+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    private enum UserDefaultsServiceKey: TestDependencyKey {
        static let testValue: any UserDefaultsServiceProtocol = UserDefaultsService(UserDefaults(suiteName: "mock")!)
        static let liveValue: any UserDefaultsServiceProtocol = UserDefaultsService(UserDefaults.standard)
    }
    
    var userDefaultsService: UserDefaultsServiceProtocol {
        get { self[UserDefaultsServiceKey.self] }
        set { self[UserDefaultsServiceKey.self] = newValue }
    }
}
