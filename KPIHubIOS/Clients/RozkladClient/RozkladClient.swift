//
//  RozkladClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import IdentifiedCollections
import Foundation

struct RozkladClient {

    let state: RozkladClientState
    let lessons: RozkladClientLessons

    static func live(userDefaultsClient: UserDefaultsClientable) -> RozkladClient {
        RozkladClient(
            state: .live(userDefaultsClient: userDefaultsClient),
            lessons: .live(userDefaultsClient: userDefaultsClient)
        )
    }

    static func mock() -> RozkladClient {
        RozkladClient(
            state: .mock(),
            lessons: .mock()
        )
    }
}

// MARK: - RozkladClientState

struct RozkladClientState {

    enum State: Equatable {
        case selected(GroupResponse)
        case notSelected
    }

    let subject: CurrentValueSubject<State, Never>
    let setState: (ClientValue<State>) -> Void
    let commit: () -> Void

    static func live(userDefaultsClient: UserDefaultsClientable) -> RozkladClientState {

        let subject = CurrentValueSubject<State, Never>(.notSelected)
        let commit: () -> Void = {
            if let group = userDefaultsClient.get(for: .groupResponse) {
                subject.send(.selected(group))
            } else {
                subject.send(.notSelected)
            }
        }
        commit()

        return RozkladClientState(
            subject: subject,
            setState: { request in
                switch request.value {
                case let .selected(group):
                    userDefaultsClient.set(group, for: .groupResponse)
                case .notSelected:
                    userDefaultsClient.remove(for: .groupResponse)
                }
                if request.commitChanges {
                    commit()
                }
            },
            commit: commit
        )
    }

    static func mock() -> RozkladClientState {
        RozkladClientState(
            subject: CurrentValueSubject<State, Never>(
                .selected(GroupResponse(id: UUID(), name: "ІВ-82"))
            ),
            setState: { _ in },
            commit: { }
        )
    }

}

// MARK: - RozkladClientLessons

struct RozkladClientLessons {

    let subject: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>
    let updatedAtSubject: CurrentValueSubject<Date?, Never>

    let set: (ClientValue<[Lesson]>) -> Void
    let modify: (ClientValue<Lesson>) -> Void
    let commit: () -> Void

    static func live(userDefaultsClient: UserDefaultsClientable) -> RozkladClientLessons {

        let subject = CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>([])
        let updatedAtSubject = CurrentValueSubject<Date?, Never>(nil)

        let commit: () -> Void = {
            subject.value = userDefaultsClient.get(for: .lessons) ?? []
            updatedAtSubject.value = userDefaultsClient.get(for: .lessonsUpdatedAt)
        }
        commit()

        return RozkladClientLessons(
            subject: subject,
            updatedAtSubject: updatedAtSubject,
            set: { request in
                userDefaultsClient.set(IdentifiedArray(uniqueElements: request.value), for: .lessons)
                userDefaultsClient.set(Date(), for: .lessonsUpdatedAt)
                if request.commitChanges {
                    commit()
                }
            },
            modify: { request in
                var lessons = IdentifiedArray(uniqueElements: userDefaultsClient.get(for: .lessons) ?? [])
                let modifiedLesson = request.value
                lessons[id: modifiedLesson.id] = modifiedLesson
                userDefaultsClient.set(lessons, for: .lessons)
                if request.commitChanges {
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
