//
//  UserDefaultsClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import Foundation
import IdentifiedCollections
import ComposableArchitecture

private enum UserDefaultsClientKey: TestDependencyKey {
    static let testValue = UserDefaultsClient.mock()
}

extension UserDefaultsClientKey: DependencyKey {
    static let liveValue = UserDefaultsClient.live()
}

extension DependencyValues {
    var userDefaultsClient: UserDefaultsClientable {
        get { self[UserDefaultsClientKey.self] }
        set { self[UserDefaultsClientKey.self] = newValue }
    }
}

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

    func get(
        for defaultKey: UserDefaultKey<Bool>
    ) -> Bool

    // MARK: - Remove

    func remove<T: Codable>(for key: UserDefaultKey<T>)

}


struct UserDefaultsClient: UserDefaultsClientable {

    init(_ defaults: UserDefaults) {
        self.defaults = defaults
    }

    // MARK: - Properties

    private let defaults: UserDefaults

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

struct UserDefaultKey<T: Codable> {
    var key: String

    init(key: String = #function) {
        self.key = key
    }
}

extension UserDefaultKey {

    static var groupResponse: UserDefaultKey<GroupResponse> { .init() }

    static var lessons: UserDefaultKey<IdentifiedArrayOf<Lesson>> { .init() }

    static var lessonsUpdatedAt: UserDefaultKey<Date> { .init() }

    static var campusUserInfo: UserDefaultKey<CampusUserInfo> { .init() }

    static var onboardingPassed: UserDefaultKey<Bool> { .init() }

    static var toggleWeek: UserDefaultKey<Bool> { .init() }

}

// MARK: - UserDefaultsClient

extension UserDefaultsClientable where Self == UserDefaultsClient {

    static func live() -> UserDefaultsClientable {
        return UserDefaultsClient(UserDefaults.standard)
    }

    static func mock() -> UserDefaultsClientable {
        return UserDefaultsClient(UserDefaults(suiteName: "mock")!)
    }

}
