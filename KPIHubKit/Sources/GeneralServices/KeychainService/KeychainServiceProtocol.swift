//
//  KeychainClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 14.06.2022.
//

import Foundation

public protocol KeychainServiceProtocol {
    func set(_ value: String?, for key: KeychainKey)
    func get(key: KeychainKey) -> String?
    func remove(for key: KeychainKey) throws
}
