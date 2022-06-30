//
//  RozkladClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import IdentifiedCollections
import Foundation


struct RozkladClientable {

    let state: RozkladClientableStateModule
    let lessons: RozkladClientableLessonsModule

    static func live(userDefaultsClient: UserDefaultsClientable) -> RozkladClientable {
        RozkladClientable(
            state: .live(userDefaultsClient: userDefaultsClient),
            lessons: .live(userDefaultsClient: userDefaultsClient)
        )
    }

    static func mock() -> RozkladClientable {
        RozkladClientable(
            state: .mock(),
            lessons: .mock()
        )
    }
}

struct ClientValue<T> {
    let value: T
    let commitChanges: Bool

    init(_ value: T, commitChanges: Bool) {
        self.value = value
        self.commitChanges = commitChanges
    }
}

struct RozkladClientableStateModule {

    enum State: Equatable {
        case selected(GroupResponse)
        case notSelected
    }

    let subject: CurrentValueSubject<State, Never>
    let setState: (ClientValue<State>) -> Void
    let commit: () -> Void

    static func live(userDefaultsClient: UserDefaultsClientable) -> RozkladClientableStateModule {

        let subject = CurrentValueSubject<State, Never>(.notSelected)
        let commit: () -> Void = {
            if let group = userDefaultsClient.get(for: .groupResponse) {
                subject.send(.selected(group))
            } else {
                subject.send(.notSelected)
            }
        }
        commit()

        return RozkladClientableStateModule(
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

    static func mock() -> RozkladClientableStateModule {
        RozkladClientableStateModule(
            subject: CurrentValueSubject<State, Never>(
                .selected(GroupResponse(id: UUID(), name: "ІВ-82"))
            ),
            setState: { _ in },
            commit: { }
        )
    }

}

struct RozkladClientableLessonsModule {

    let subject: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>
    let updatedAtSubject: CurrentValueSubject<Date?, Never>

    let set: (ClientValue<[Lesson]>) -> Void
    let modify: (ClientValue<Lesson>) -> Void
    let commit: () -> Void

    static func live(userDefaultsClient: UserDefaultsClientable) -> RozkladClientableLessonsModule {

        let subject = CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>([])
        let updatedAtSubject = CurrentValueSubject<Date?, Never>(nil)

        let commit: () -> Void = {
            subject.value = userDefaultsClient.get(for: .lessons) ?? []
            updatedAtSubject.value = userDefaultsClient.get(for: .lessonsUpdatedAt)
        }
        commit()

        return RozkladClientableLessonsModule(
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

    static func mock() -> RozkladClientableLessonsModule {
        RozkladClientableLessonsModule(
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



/*
final class RozkladClient {

    // MARK: - State

    final class StateModule {

        private let userDefaultsClient: UserDefaultsClientable
        
        init(userDefaultsClient: UserDefaultsClientable) {
            self.userDefaultsClient = userDefaultsClient
        }

        enum State: Equatable {
            case selected(GroupResponse)
            case notSelected
        }

        lazy var subject: CurrentValueSubject<State, Never> = {
            if let group = userDefaultsClient.get(for: .groupResponse) {
                return .init(.selected(group))
            } else {
                return .init(.notSelected)
            }
        }()

        func select(group: GroupResponse, commitChanges: Bool) {
            userDefaultsClient.set(group, for: .groupResponse)
            if commitChanges {
                commit()
            }
        }

        func deselect(commitChanges: Bool) {
            userDefaultsClient.remove(for: .groupResponse)
            userDefaultsClient.remove(for: .lessons)
            userDefaultsClient.remove(for: .lessonsUpdatedAt)
            if commitChanges {
                commit()
            }
        }

        func commit() {
            if let group = userDefaultsClient.get(for: .groupResponse) {
                subject.send(.selected(group))
            } else {
                subject.send(.notSelected)
            }
        }
        
    }

    var state: StateModule

    // MARK: - Lessons

    final class LessonsModule {

        private let userDefaultsClient: UserDefaultsClientable

        init(userDefaultsClient: UserDefaultsClientable) {
            self.userDefaultsClient = userDefaultsClient
        }

        lazy var subject: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never> = {
            if let lessons = userDefaultsClient.get(for: .lessons) {
                return .init(lessons)
            } else {
                return .init([])
            }
        }()

        lazy var uploadedAt: CurrentValueSubject<Date?, Never> = {
            if let uploadedAt = userDefaultsClient.get(for: .lessonsUpdatedAt) {
                return .init(uploadedAt)
            } else {
                return .init(nil)
            }
        }()

        func set(lessons: [Lesson], commitChanges: Bool) {
            userDefaultsClient.set(IdentifiedArray(uniqueElements: lessons), for: .lessons)
            userDefaultsClient.set(Date(), for: .lessonsUpdatedAt)
            if commitChanges {
                commit()
            }
        }

        func modify(with lesson: Lesson, commitChanges: Bool) {
            var lessons = IdentifiedArray(uniqueElements: userDefaultsClient.get(for: .lessons) ?? [])
            lessons[id: lesson.id] = lesson
            userDefaultsClient.set(lessons, for: .lessons)
            if commitChanges {
                commit()
            }
        }

        func commit() {
            if let lessons = userDefaultsClient.get(for: .lessons) {
                subject.send(lessons)
            } else {
                subject.send([])
            }

            if let lessonsUpdatedAt = userDefaultsClient.get(for: .lessonsUpdatedAt) {
                uploadedAt.send(lessonsUpdatedAt)
            } else {
                uploadedAt.send(nil)
            }
        }

    }

    var lessons: LessonsModule

    // MARK: - Lifecycle

    static func live(userDefaultsClient: UserDefaultsClientable) -> RozkladClient {
        RozkladClient(userDefaultsClient: userDefaultsClient)
    }

    static func mock(
        userDefaultsClient: UserDefaultsClientable = mockDependencies.userDefaults
    ) -> RozkladClient {
        RozkladClient(userDefaultsClient: userDefaultsClient)
    }

    private init(userDefaultsClient: UserDefaultsClientable) {
        self.state = StateModule(userDefaultsClient: userDefaultsClient)
        self.lessons = LessonsModule(userDefaultsClient: userDefaultsClient)
    }

}
*/
