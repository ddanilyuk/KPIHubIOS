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
//            setVerificationID: { setVerificationID(verificationID: $0, defaults: defaults) },
//            getVerificationID: { getVerificationID(defaults: defaults) },
//            setUser: { setUser(user: $0, defaults: defaults, encoder: encoder) },
//            getUser: { getUser(defaults: defaults, decoder: decoder) }
//        )
//    }
//
//}
//
//fileprivate extension UserDefaultsClient {
//
//    // MARK: - VerificationID
//
//    static func setVerificationID(
//        verificationID: String,
//        defaults: UserDefaults
//    ) {
//        defaults.set(verificationID, forKey: Key.authVerificationID.rawValue)
//    }
//
//    static func getVerificationID(
//        defaults: UserDefaults
//    ) -> String {
//        defaults.string(forKey: Key.authVerificationID.rawValue) ?? ""
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
