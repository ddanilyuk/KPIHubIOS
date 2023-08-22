//
//  RozkladServiceLessons+Mock.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import IdentifiedCollections
import Combine

extension RozkladServiceLessons {
    static func mock() -> RozkladServiceLessons {
        RozkladServiceLessons(
            subject: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>(
                .init(uniqueElements: LessonResponse.mocked.map { Lesson(lessonResponse: $0) })
            ),
            updatedAtSubject: CurrentValueSubject<Date?, Never>(
                Date()
            ),
            set: { _ in },
            modify: { _ in },
            commit: { }
        )
    }
}
