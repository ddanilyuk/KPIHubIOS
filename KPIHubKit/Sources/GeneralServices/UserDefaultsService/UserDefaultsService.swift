//
//  UserDefaultsService+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Dependencies

struct UserDefaultsService: UserDefaultsServiceProtocol {
    private let defaults: UserDefaults
    
    init(_ defaults: UserDefaults) {
        self.defaults = defaults
    }
    
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
    
    func remove<T: Codable>(
        for defaultKey: UserDefaultKey<T>
    ) {
        defaults.removeObject(forKey: defaultKey.key)
        defaults.synchronize()
    }
}
