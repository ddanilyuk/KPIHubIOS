//
//  RozkladClientLessons.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import IdentifiedCollections
import Combine
import Dependencies

private enum RozkladClientLessonsKey: TestDependencyKey {
    static let testValue = RozkladClientLessons.mock()
}

extension RozkladClientLessonsKey: DependencyKey {
    static let liveValue = RozkladClientLessons.live()
}

extension DependencyValues {
    var rozkladClientLessons: RozkladClientLessons {
        get { self[RozkladClientLessonsKey.self] }
        set { self[RozkladClientLessonsKey.self] = newValue }
    }
}

struct RozkladClientLessons {

    let subject: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>
    let updatedAtSubject: CurrentValueSubject<Date?, Never>

    let set: (ClientValue<[Lesson]>) -> Void
    let modify: (ClientValue<Lesson>) -> Void
    let commit: () -> Void

    static func live() -> RozkladClientLessons {
        @Dependency(\.userDefaultsService) var userDefaultsService
        let subject = CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>([])
        let updatedAtSubject = CurrentValueSubject<Date?, Never>(nil)

        let commit: () -> Void = {
            subject.value = userDefaultsService.get(for: .lessons) ?? []
            updatedAtSubject.value = userDefaultsService.get(for: .lessonsUpdatedAt)
        }
        commit()

        return RozkladClientLessons(
            subject: subject,
            updatedAtSubject: updatedAtSubject,
            set: { clientValue in
                userDefaultsService.set(IdentifiedArray(uniqueElements: clientValue.value), for: .lessons)
                userDefaultsService.set(Date(), for: .lessonsUpdatedAt)
                if clientValue.commitChanges {
                    commit()
                }
            },
            modify: { clientValue in
                var lessons = IdentifiedArray(uniqueElements: userDefaultsService.get(for: .lessons) ?? [])
                let modifiedLesson = clientValue.value
                lessons[id: modifiedLesson.id] = modifiedLesson
                userDefaultsService.set(lessons, for: .lessons)
                if clientValue.commitChanges {
                    commit()
                }
            },
            commit: commit
        )
    }

    static func mock() -> RozkladClientLessons {
        RozkladClientLessons(
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
