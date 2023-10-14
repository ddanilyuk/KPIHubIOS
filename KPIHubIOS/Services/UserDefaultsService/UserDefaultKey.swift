//
//  UserDefaultKey.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import IdentifiedCollections
import Foundation

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
