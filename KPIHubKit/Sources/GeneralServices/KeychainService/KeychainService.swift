//
//  KeychainService+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import KeychainAccess

final class KeychainService: KeychainServiceProtocol {
    private let keychain: Keychain
    
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
