//
//  RozkladServiceLessons+Mock.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import IdentifiedCollections
import Combine
import Dependencies

extension RozkladServiceLessons {
    static func mock() -> RozkladServiceLessons {
        return RozkladServiceLessons(
            subject: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>(
                .init(uniqueElements: LessonResponse.mocked.map { Lesson(lessonResponse: $0) })
            ),
            updatedAtSubject: CurrentValueSubject<Date?, Never>(
                Date(timeIntervalSince1970: 1695329230)
            ),
            set: { _ in },
            modify: { _ in },
            commit: { }
        )
    }
}
