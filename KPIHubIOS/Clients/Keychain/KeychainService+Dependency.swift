//
//  KeychainService+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies
import KeychainAccess

extension DependencyValues {
    private enum KeychainClientKey: DependencyKey {
        static let liveValue: any KeychainServiceProtocol = KeychainService()
        static let testValue: any KeychainServiceProtocol = KeychainService(keychain: Keychain(service: "mock"))
    }
    
    var keychainService: KeychainServiceProtocol {
        get { self[KeychainClientKey.self] }
        set { self[KeychainClientKey.self] = newValue }
    }
}
