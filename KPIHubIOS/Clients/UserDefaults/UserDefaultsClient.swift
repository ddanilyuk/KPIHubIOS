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

struct UserDefaultKey<T: Codable> {
    var customKey: String?
}

extension UserDefaultKey {
    var key: String {
        customKey ?? String(describing: self)
    }
}

extension UserDefaultKey {

    static var groupResponse: UserDefaultKey<GroupResponse> { .init() }

    static var lessons: UserDefaultKey<IdentifiedArrayOf<Lesson>> { .init() }

    static var lessonsUpdatedAt: UserDefaultKey<Date> { .init() }

    static var campusUserInfo: UserDefaultKey<CampusUserInfo> { .init() }

    static var onboardingPassed: UserDefaultKey<Bool> { .init() }

}
