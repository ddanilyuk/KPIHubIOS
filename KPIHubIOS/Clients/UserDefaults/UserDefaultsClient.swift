//
//  UserDefaultsClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import Foundation
import IdentifiedCollections

protocol UserDefaultsClientable {

    // MARK: - Set

//    func set<T: Codable>(
//        _ value: T,
//        for defaultKey: UserDefaultKey<T>
//    )

    func set<T: Codable, Key: StorageKey>(
        _ value: T,
        key: Key.Type
    ) where Key.Value == T


    func set<T: Codable, KeyTest: StorageKeyV2>(
        _ value: T,
        keyTest: KeyTest
    ) where KeyTest.Value == T

//    func set<T: Codable>(
//        _ value: T,
//        for defaultKey: UserDefaultKey<T>,
//        encoder: JSONEncoder
//    )

    func set<T: Codable, Key: StorageKey>(
        _ value: T,
        key: Key.Type,
        encoder: JSONEncoder
    ) where Key.Value == T


    // MARK: - Get

//    func get<T: Codable>(
//        for defaultKey: UserDefaultKey<T>
//    ) -> T?

    func get<T: Codable, Key: StorageKey>(
        key: Key.Type
    ) -> T? where Key.Value == T

//    func get<T: Codable>(
//        for defaultKey: UserDefaultKey<T?>
//    ) -> T?

//    func get<T: Codable, Key: StorageKey>(
//        key: Key
//    ) -> T? where Key.Value == T

//    func get(
//        for defaultKey: UserDefaultKey<Bool>
//    ) -> Bool

    func get<Key: StorageKey>(
        key: Key.Type
    ) -> Bool? where Key.Value == Bool

    // MARK: - Remove

    func remove<Key: StorageKey>(for key: Key.Type)

//    static func live() -> UserDefaultsClientable
//    static func mock() -> UserDefaultsClientable
}


final class UserDefaultsClient: UserDefaultsClientable {

    static func live() -> UserDefaultsClient {
        return UserDefaultsClient(UserDefaults.standard)
    }

    static func mock() -> UserDefaultsClientable {
        return UserDefaultsClient(UserDefaults(suiteName: "mock")!)
    }

    private init(_ defaults: UserDefaults) {
        self.defaults = defaults
    }

    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Set

//    func set<T: Codable>(
//        _ value: T,
//        for defaultKey: UserDefaultKey<T>
//    ) {
//        guard let encoded = try? JSONEncoder().encode(value) else {
//            return
//        }
//        defaults.set(encoded, forKey: defaultKey.key)
//    }

    func set<T: Codable, Key: StorageKey>(
        _ value: T,
        key: Key.Type
    ) where T == Key.Value {
        guard let encoded = try? JSONEncoder().encode(value) else {
            return
        }
        defaults.set(encoded, forKey: key.string)
    }

    func set<T: Codable, KeyTest: StorageKeyV2>(
        _ value: T,
        keyTest: KeyTest
    ) where T == KeyTest.Value {
        guard let encoded = try? JSONEncoder().encode(value) else {
            return
        }
        defaults.set(encoded, forKey: keyTest.string)
    }

//    func set<T: Codable>(
//        _ value: T,
//        for defaultKey: UserDefaultKey<T>,
//        encoder: JSONEncoder = JSONEncoder()
//    ) {
//        guard let encoded = try? encoder.encode(value) else {
//            return
//        }
//        defaults.set(encoded, forKey: defaultKey.key)
//    }

    func set<T: Codable, Key: StorageKey>(
        _ value: T,
        key: Key.Type,
        encoder: JSONEncoder = JSONEncoder()
    ) where T == Key.Value {
        guard let encoded = try? encoder.encode(value) else {
            return
        }
        defaults.set(encoded, forKey: key.string)
    }

    // MARK: - Get

//    func get<T: Codable>(
//        for defaultKey: UserDefaultKey<T>
//    ) -> T? {
//        return get(for: defaultKey.key)
//    }

    func get<T: Codable, Key: StorageKey>(
        key: Key.Type
    ) -> T? where T == Key.Value {
        return get(for: key.string)
    }

//    func get<T: Codable>(
//        for defaultKey: UserDefaultKey<T?>
//    ) -> T? {
//        return get(for: defaultKey.key)
//    }

//    func get(
//        for defaultKey: UserDefaultKey<Bool>
//    ) -> Bool {
//        return get(for: defaultKey) ?? false
//    }

    func get<Key: StorageKey>(
        key: Key.Type
    ) -> Bool where Key.Value == Bool {
        return get(for: key.string) ?? false
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

    func remove<Key: StorageKey>(
        for key: Key.Type
    ) {
        defaults.removeObject(forKey: key.string)
        defaults.synchronize()
    }

}

// MARK: - UserDefaultKey

struct UserDefaultKey<T: Codable> {
    var definedKey: String?
}

extension UserDefaultKey {
    var key: String {
        definedKey ?? String(describing: self)
    }
}

extension UserDefaultKey {
    static var group: UserDefaultKey<GroupResponse> {
        .init()
    }
}


//
//// MARK: - UserDefaultKey + ExpressibleByStringLiteral
//
//extension UserDefaultKey: ExpressibleByStringLiteral {
//
//    init(stringLiteral value: String) {
//        self.key = value
//    }
//
//}
//
//extension UserDefaultKey {
//
//    static var group: UserDefaultKey<GroupResponse> {
//        "group"
//    }
//
//    static var lessons: UserDefaultKey<IdentifiedArrayOf<Lesson>> {
//        "lessons"
//    }
//
//    static var lessonsUpdatedAt: UserDefaultKey<Date> {
//        "lessonsUpdatedAt"
//    }
//
//
//    static var campusUserInfo: UserDefaultKey<CampusUserInfo> {
//        "campusUserInfo"
//    }
//
//    static var onboardingPassed: UserDefaultKey<Bool> {
//        "onboardingPassed"
//    }
//
//}



struct GroupResponseKey: StorageKey {
    typealias Value = GroupResponse
}

struct LessonsKey: StorageKey {
    typealias Value = IdentifiedArrayOf<Lesson>
}

struct LessonsUpdatedDateKey: StorageKey {
    typealias Value = Date
}

struct CampusUserInfoKey: StorageKey {
    typealias Value = CampusUserInfo
}

struct OnboardingPassedKey: StorageKey {
    typealias Value = Bool
}

public protocol StorageKey {
    associatedtype Value

    static var string: String { get }
}

extension StorageKey {
    static var string: String {
        return String(describing: Self.self)
    }
}

struct TestString: StorageKey {
    typealias Value = String
    fileprivate init() {}
}

extension StorageKey {

    static var group: some StorageKey {
        TestString()
    }
}


public protocol StorageKeyV2 {
    associatedtype Value

    var string: String { get }
}

extension StorageKeyV2 {
    var string: String {
        return String(describing: self)
    }
}

//extension StorageKey {
//    static var test: TestKey.Type { TestKey.self }
//}
//
//enum Namespace {
//
//
//}

//TestKey()

struct TestKey: StorageKeyV2 {
    typealias Value = String
    fileprivate init() {}
}

extension StorageKeyV2 {
    static var test: TestKey { TestKey() }
}







struct TestKey2: StorageKeyV2 {
    typealias Value = Int

    fileprivate init() {}
}

extension StorageKeyV2 where Self == TestKey2 {
    static var test: Self { Self() }
}
