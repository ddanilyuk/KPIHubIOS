//
//  UserDefaultsClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import Foundation

protocol UserDefaultsClientable {

    // MARK: - Set

    func set<T: Codable>(
        _ value: T,
        for defaultKey: UserDefaultKey<T>
    )

    func set<T: Codable>(
        _ value: T,
        for defaultKey: UserDefaultKey<T>,
        encoder: JSONEncoder
    )

    // MARK: - Get

    func get<T: Codable>(
        for defaultKey: UserDefaultKey<T>
    ) -> T?

    func get<T: Codable>(
        for defaultKey: UserDefaultKey<T?>
    ) -> T?

    func get(
        for defaultKey: UserDefaultKey<Bool>
    ) -> Bool

    // MARK: - Remove

    func remove<T: Codable>(for key: UserDefaultKey<T>)
}


final class UserDefaultsClient: UserDefaultsClientable {

    static func live() -> UserDefaultsClient {
        return UserDefaultsClient()
    }
    
    private init() { }

    // MARK: - Properties

    private let defaults = UserDefaults.standard

    // MARK: - Set

    func set<T: Codable>(
        _ value: T,
        for defaultKey: UserDefaultKey<T>
    ) {
        guard let encoded = try? JSONEncoder().encode(value) else {
            return
        }
        defaults.set(encoded, forKey: defaultKey.key)
    }

    func set<T: Codable>(
        _ value: T,
        for defaultKey: UserDefaultKey<T>,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        guard let encoded = try? encoder.encode(value) else {
            return
        }
        defaults.set(encoded, forKey: defaultKey.key)
    }

    // MARK: - Get

    func get<T: Codable>(
        for defaultKey: UserDefaultKey<T>
    ) -> T? {
        return get(for: defaultKey.key)
    }

    func get<T: Codable>(
        for defaultKey: UserDefaultKey<T?>
    ) -> T? {
        return get(for: defaultKey.key)
    }

    func get(
        for defaultKey: UserDefaultKey<Bool>
    ) -> Bool {
        return get(for: defaultKey) ?? false
    }

    private func get<T: Codable>(
        for key: String
    ) -> T? {
        guard
            let data = defaults.object(forKey: key) as? Data,
            let value = try? JSONDecoder().decode(T.self, from: data)
        else {
            return nil
        }
        return value
    }

    // MARK: - Remove

    func remove<T: Codable>(
        for defaultKey: UserDefaultKey<T>
    ) {
        defaults.removeObject(forKey: defaultKey.key)
        defaults.synchronize()
    }
}

// MARK: - UserDefaultKey

struct UserDefaultKey<T: Codable> {

    var key: String
}

// MARK: - UserDefaultKey + ExpressibleByStringLiteral

extension UserDefaultKey: ExpressibleByStringLiteral {

    init(stringLiteral value: String) {
        self.key = value
    }
}

extension UserDefaultKey {

    static var group: UserDefaultKey<GroupResponse> {
        "group"
    }

    static var lessons: UserDefaultKey<[Lesson]> {
        "lessons"
    }

    static var campusCredentials: UserDefaultKey<CampusCredentials> {
        "campusCredentials"
    }

    static var campusUserInfo: UserDefaultKey<CampusUserInfo> {
        "campusUserInfo"
    }

}


struct CampusCredentials: Codable {
    let username: String
    let password: String
}

struct CampusUserInfo: Codable, Equatable {

    let groupName: String

}


