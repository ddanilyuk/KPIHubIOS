//
//  UserDefaultsClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import Foundation

protocol UserDefaultsServiceable {

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

final class UserDefaultsService: UserDefaultsServiceable {

    static func live() -> UserDefaultsService {
        return UserDefaultsService()
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

    static var group: UserDefaultKey<Group> {
        "group"
    }

    static var lessons: UserDefaultKey<[Lesson]> {
        "lessons"
    }
}


/*
struct UserDefaultsServiceable {

    // MARK: - Set

    var set: (
        _ value: T,
        for defaultKey: UserDefaultKey<T>
    ) -> Void

    var set<T: Codable>(
        _ value: T,
        for defaultKey: UserDefaultKey<T>,
        encoder: JSONEncoder
    ) -> Void

    // MARK: - Get

    var get<T: Codable>(
        for defaultKey: UserDefaultKey<T>
    ) -> T?

    var get<T: Codable>(
        for defaultKey: UserDefaultKey<T?>
    ) -> T?

    func get(
        for defaultKey: UserDefaultKey<Bool>
    ) -> Bool

    // MARK: - Remove

    func remove<T: Codable>(for key: UserDefaultKey<T>)
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



struct UserDefaultsClient {

    var setGroup: (Group) -> Void
    var getGroup: () -> (Group)

    var setLessons: ([Lesson]) -> Void
    var getLessons: () -> [Lesson]

}

// MARK: - Key

extension UserDefaultsClient {

    enum Key: String {
        case group
        case lessons
    }

}
*/
