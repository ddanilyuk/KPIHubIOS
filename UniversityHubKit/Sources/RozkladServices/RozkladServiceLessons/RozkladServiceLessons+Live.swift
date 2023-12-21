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
import RozkladModels
import GeneralServices

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

        private let subject = CurrentValueSubject<IdentifiedArrayOf<RozkladLessonModel>, Never>([])
        private let updatedAtSubject = CurrentValueSubject<Date?, Never>(nil)
        
        init() {
            commit()
        }
        
        func lessonsStream() -> AsyncStream<IdentifiedArrayOf<RozkladLessonModel>> {
            AsyncStream(subject.values)
        }
        
        func currentLessons() -> IdentifiedArrayOf<RozkladLessonModel> {
            subject.value
        }
        
        func updatedAtStream() -> AsyncStream<Date?> {
            AsyncStream(updatedAtSubject.values)
        }
        
        func currentUpdatedAt() -> Date? {
            updatedAtSubject.value
        }
        
        func set(clientValue: ClientValue<[RozkladLessonModel]>) {
            userDefaultsService.set(
                IdentifiedArray(uniqueElements: clientValue.value),
                for: .lessons
            )
            userDefaultsService.set(Date(), for: .lessonsUpdatedAt)
            if clientValue.commitChanges {
                commit()
            }
        }
        
        func modify(clientValue: ClientValue<RozkladLessonModel>) {
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
        
        func getLessons(groupID: UUID) async throws -> [RozkladLessonModel] {
            let decodedResponse = try await apiService.decodedResponse(
                for: .api(.group(groupID, .lessons)),
                as: LessonsResponse.self
            )
            let lesson = decodedResponse.value.lessons.map(Lesson.init)
            return lesson.map { RozkladLessonModel(lesson: $0) }
        }
    }
}

// TODO: Implement migration
extension UserDefaultKey {
    public typealias StoreType = IdentifiedArrayOf<RozkladLessonModel>
    public static var lessons: UserDefaultKey<StoreType> {
        UserDefaultKey<StoreType>(key: "lessons")
    }
}
