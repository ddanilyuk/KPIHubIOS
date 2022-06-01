//
//  UserDefaultsClientLive.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import Foundation
//
//extension UserDefaultsClient {
//
//    static func live() -> UserDefaultsClient {
//        let defaults = UserDefaults.standard
//        let encoder = JSONEncoder()
//        let decoder = JSONDecoder()
//        return UserDefaultsClient(
//            setGroup: { setGroup(verificationID: $0, defaults: defaults) },
//            getGroup: { getGroup(defaults: defaults) },
//            setLessons: { setLessons(user: $0, defaults: defaults, encoder: encoder) },
//            getLessons: { getUser(defaults: defaults, decoder: decoder) }
//        )
//    }
//
//}
//
//fileprivate extension UserDefaultsClient {
//
//    // MARK: - VerificationID
//
//    static func setGroup(
//        group: Group,
//        defaults: UserDefaults
//    ) {
//        defaults.set(group, forKey: Key.group.rawValue)
//    }
//
//    static func getVerificationID(
//        defaults: UserDefaults
//    ) -> String {
//        defaults.string(forKey: Key.group.rawValue) ?? ""
//    }
//
//    // MARK: - User
//
//    static func setUser(
//        user: User?,
//        defaults: UserDefaults,
//        encoder: JSONEncoder
//    ) {
//        if let user = user {
//            guard let encoded = try? encoder.encode(user) else {
//                return
//            }
//            defaults.set(encoded, forKey: Key.user.rawValue)
//
//        } else {
//            defaults.removeObject(forKey: Key.user.rawValue)
//        }
//    }
//
//    static func getUser(
//        defaults: UserDefaults,
//        decoder: JSONDecoder
//    ) -> User? {
//        guard
//            let userData = defaults.object(forKey: Key.user.rawValue) as? Data,
//            let user = try? decoder.decode(User.self, from: userData)
//        else {
//            return nil
//        }
//        return user
//    }
//}
