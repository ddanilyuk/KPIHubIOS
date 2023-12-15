//
//  UserDefaultsService.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation

public protocol UserDefaultsServiceProtocol {
    func set<T: Codable>(
        _ value: T,
        for defaultKey: UserDefaultKey<T>
    )

    func set<T: Codable>(
        _ value: T,
        for defaultKey: UserDefaultKey<T>,
        encoder: JSONEncoder
    )

    func get<T: Codable>(
        for defaultKey: UserDefaultKey<T>
    ) -> T?

    func get(
        for defaultKey: UserDefaultKey<Bool>
    ) -> Bool

    func remove<T: Codable>(for key: UserDefaultKey<T>)
}
