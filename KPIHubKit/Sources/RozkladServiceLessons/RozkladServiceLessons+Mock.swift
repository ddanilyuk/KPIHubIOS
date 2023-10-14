//
//  RozkladServiceLessons+Mock.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import IdentifiedCollections
import Common

extension RozkladServiceLessons {
    static func mock() -> RozkladServiceLessons {
        RozkladServiceLessons(
            lessonsStream: { .never },
            currentLessons: { IdentifiedArray(uniqueElements: LessonResponse.mocked.map { Lesson(lessonResponse: $0) }) },
            updatedAtStream: { .never },
            currentUpdatedAt: { Date(timeIntervalSince1970: 1695329230) },
            set: { _ in },
            modify: { _ in },
            commit: { }
        )
    }
}
