//
//  UserDefaultKey.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import IdentifiedCollections
import Foundation

public struct UserDefaultKey<T: Codable> {
    public var key: String
    
    public init(key: String) {
        self.key = key
    }

    public init(_ key: String = #function) {
        self.key = key
    }
}

extension UserDefaultKey {
    public static var groupResponse: UserDefaultKey<GroupResponse> { .init() }

//    public static var lessons: UserDefaultKey<IdentifiedArrayOf<Lesson>> { .init() }

    public static var lessonsUpdatedAt: UserDefaultKey<Date> { .init() }

    public static var campusUserInfo: UserDefaultKey<CampusUserInfo> { .init() }

    public static var onboardingPassed: UserDefaultKey<Bool> { .init() }

    public static var toggleWeek: UserDefaultKey<Bool> { .init() }
}
