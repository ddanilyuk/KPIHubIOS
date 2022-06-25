//
//  RozkladClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import IdentifiedCollections
import Foundation

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
