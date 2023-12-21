//
//  KeychainService+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies
import KeychainAccess

extension DependencyValues {
    private enum KeychainServiceKey: DependencyKey {
        static let liveValue: any KeychainServiceProtocol = KeychainService()
        static let testValue: any KeychainServiceProtocol = KeychainService(keychain: Keychain(service: "mock"))
    }
    
    public var keychainService: KeychainServiceProtocol {
        get { self[KeychainServiceKey.self] }
        set { self[KeychainServiceKey.self] = newValue }
    }
}
