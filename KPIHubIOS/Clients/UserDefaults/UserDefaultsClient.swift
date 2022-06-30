//
//  UserDefaultsClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import Foundation
import IdentifiedCollections


struct TestDefaults {

    struct Request<T: Codable> {
        var value: T
        var key: UserDefaultKey<T>
    }

//    func set(_ request: any Request) -> Void {
//
//    }
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

//    static func mock() -> Self
}





private struct UserDefaultsClientImplementation: UserDefaultsClientable {

//    static func live() -> UserDefaultsClient {
//        return UserDefaultsClient(UserDefaults.standard)
//    }
//
//    static func mock() -> UserDefaultsClient {
//        return UserDefaultsClient(UserDefaults(suiteName: "mock")!)
//    }
    
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

enum Test {
//    typealias TestType = UserDefaultsClientable

    static func live() -> UserDefaultsClientable {
        return UserDefaultsClientImplementation(UserDefaults.standard)
    }

    static func mock() -> UserDefaultsClientable {
        return UserDefaultsClientImplementation(UserDefaults(suiteName: "mock")!)
    }
}

extension UserDefaultsClientable {
    static func live() -> UserDefaultsClientable {
        return UserDefaultsClientImplementation(UserDefaults.standard)
    }

    static func mock() -> UserDefaultsClientable {
        return UserDefaultsClientImplementation(UserDefaults(suiteName: "mock")!)
    }

}

let user: UserDefaultsClientable = Test.live()

// This code is prepared for migrating to new composable-architecture
// design using @Dependency(\.keyPath)
struct Dependencies {

    var mode: Mode

    enum Mode {
        case mock
        case live
    }
}

public protocol MockDependencyKey {
    associatedtype Value
    
    static var mock: Value { get }
}


public protocol DependencyKey: MockDependencyKey {
    static var live: Value { get }
}

let liveDependencies = Dependencies(mode: .live)
let mockDependencies = Dependencies(mode: .mock)

extension Dependencies {

    public var userDefaults: UserDefaultsClientable {
        get {
            switch self.mode {
            case .live:
                return UserDefaultsKey.live
            case .mock:
                return UserDefaultsKey.mock
            }
        }
    }

    private enum UserDefaultsKey: DependencyKey {
        static let live: any UserDefaultsClientable = UserDefaultsClientImplementation(UserDefaults.standard)
        static let mock: any UserDefaultsClientable = UserDefaultsClientImplementation(UserDefaults(suiteName: "mock")!)
    }

}
