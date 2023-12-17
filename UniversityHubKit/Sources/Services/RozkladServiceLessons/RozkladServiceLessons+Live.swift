//
//  RozkladServiceLessons+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Combine
import Dependencies
import IdentifiedCollections

extension RozkladServiceLessons {
    static func live() -> RozkladServiceLessons {
        let liveHelper = LiveHelper()
        return RozkladServiceLessons(
            lessonsStream: liveHelper.lessonsStream,
            currentLessons: liveHelper.currentLessons,
            updatedAtStream: liveHelper.updatedAtStream,
            currentUpdatedAt: liveHelper.currentUpdatedAt,
            set: liveHelper.set,
            modify: liveHelper.modify,
            commit: liveHelper.commit,
            getLessons: liveHelper.getLessons
        )
    }
}

private extension RozkladServiceLessons {
    struct LiveHelper {
        @Dependency(\.userDefaultsService) var userDefaultsService
        @Dependency(\.apiService) var apiService

        private let subject = CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>([])
        private let updatedAtSubject = CurrentValueSubject<Date?, Never>(nil)
        
        init() {
            commit()
        }
        
        func lessonsStream() -> AsyncStream<IdentifiedArrayOf<Lesson>> {
            AsyncStream(subject.values)
        }
        
        func currentLessons() -> IdentifiedArrayOf<Lesson> {
            subject.value
        }
        
        func updatedAtStream() -> AsyncStream<Date?> {
            AsyncStream(updatedAtSubject.values)
        }
        
        func currentUpdatedAt() -> Date? {
            updatedAtSubject.value
        }
        
        func set(clientValue: ClientValue<[Lesson]>) {
            userDefaultsService.set(IdentifiedArray(uniqueElements: clientValue.value), for: .lessons)
            userDefaultsService.set(Date(), for: .lessonsUpdatedAt)
            if clientValue.commitChanges {
                commit()
            }
        }
        
        func modify(clientValue: ClientValue<Lesson>) {
            var lessons = IdentifiedArray(uniqueElements: userDefaultsService.get(for: .lessons) ?? [])
            let modifiedLesson = clientValue.value
            lessons[id: modifiedLesson.id] = modifiedLesson
            userDefaultsService.set(lessons, for: .lessons)
            if clientValue.commitChanges {
                commit()
            }
        }
        
        func commit() {
            subject.value = userDefaultsService.get(for: .lessons) ?? []
            updatedAtSubject.value = userDefaultsService.get(for: .lessonsUpdatedAt)
        }
        
        func getLessons(group: GroupResponse) async throws -> [Lesson] {
            let decodedResponse = try await apiService.decodedResponse(
                for: .api(.group(group.id, .lessons)),
                as: LessonsResponse.self
            )
            return decodedResponse.value.lessons.map(Lesson.init)
        }
    }
}
