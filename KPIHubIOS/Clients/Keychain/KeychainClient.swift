//
//  KeychainClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 14.06.2022.
//

import Foundation
import KeychainAccess
import ComposableArchitecture

private enum KeychainClientKey: DependencyKey {
    static let liveValue = KeychainClient.live()
    static let testValue = KeychainClient.mock()
}

extension DependencyValues {
    var keychainClient: KeychainClientable {
        get { self[KeychainClientKey.self] }
        set { self[KeychainClientKey.self] = newValue }
    }
}

protocol KeychainClientable {
    func set(_ value: String?, for key: KeychainKey)
    func get(key: KeychainKey) -> String?
    func remove(for key: KeychainKey) throws
}

final class KeychainClient: KeychainClientable {

    let keychain: Keychain

    init(keychain: Keychain = Keychain()) {
        self.keychain = keychain
    }

    func set(_ value: String?, for key: KeychainKey) {
        keychain[key.rawValue] = value
    }

    func get(key: KeychainKey) -> String? {
        keychain[key.rawValue]
    }

    func remove(for key: KeychainKey) throws {
        try keychain.remove(key.rawValue)
    }

}

enum KeychainKey: String {
    case campusUsername
    case campusPassword
}

extension KeychainClientable where Self == KeychainClient {

    static func live() -> KeychainClientable {
        KeychainClient()
    }

    static func mock() -> KeychainClientable {
        KeychainClient(keychain: Keychain(service: "mock"))
    }
}
