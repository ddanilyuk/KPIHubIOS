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

        private let userDefaultsClient: UserDefaultsClient
        
        init(userDefaultsClient: UserDefaultsClient) {
            self.userDefaultsClient = userDefaultsClient
        }

        enum State: Equatable {
            case selected(GroupResponse)
            case notSelected
        }

        lazy var subject: CurrentValueSubject<State, Never> = {
            if let group = userDefaultsClient.get(key: GroupResponseKey.self) {
                return .init(.selected(group))
            } else {
                return .init(.notSelected)
            }
        }()

        func select(group: GroupResponse, commitChanges: Bool) {
            userDefaultsClient.set(group, key: GroupResponseKey.self)
            if commitChanges {
                commit()
            }
        }

        func deselect(commitChanges: Bool) {
            userDefaultsClient.remove(for: GroupResponseKey.self)
            if commitChanges {
                commit()
            }
        }

        func commit() {
            if let group = userDefaultsClient.get(key: GroupResponseKey.self) {
                subject.send(.selected(group))
            } else {
                subject.send(.notSelected)
            }
        }
        
    }

    var state: StateModule

    // MARK: - Lessons

    final class LessonsModule {

        private let userDefaultsClient: UserDefaultsClient

        init(userDefaultsClient: UserDefaultsClient) {
            self.userDefaultsClient = userDefaultsClient
        }

        lazy var subject: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never> = {
            if let lessons = userDefaultsClient.get(key: LessonsKey.self) {
                return .init(lessons)
            } else {
                return .init([])
            }
        }()

        lazy var uploadedAt: CurrentValueSubject<Date?, Never> = {
            if let uploadedAt = userDefaultsClient.get(key: LessonsUpdatedDateKey.self) {
                return .init(uploadedAt)
            } else {
                return .init(nil)
            }
        }()

        func set(lessons: [Lesson], commitChanges: Bool) {
            userDefaultsClient.set(IdentifiedArray(uniqueElements: lessons), key: LessonsKey.self)
            userDefaultsClient.set(Date(), key: LessonsUpdatedDateKey.self)
            if commitChanges {
                commit()
            }
        }

        func modify(with lesson: Lesson, commitChanges: Bool) {
            var lessons = IdentifiedArray(uniqueElements: userDefaultsClient.get(key: LessonsKey.self) ?? [])
            lessons[id: lesson.id] = lesson
            userDefaultsClient.set(lessons, key: LessonsKey.self)
            if commitChanges {
                commit()
            }
        }

        func commit() {
            if let lessons = userDefaultsClient.get(key: LessonsKey.self) {
                subject.send(lessons)
            } else {
                subject.send([])
            }

            if let lessonsUpdatedAt = userDefaultsClient.get(key: LessonsUpdatedDateKey.self) {
                uploadedAt.send(lessonsUpdatedAt)
            } else {
                uploadedAt.send(nil)
            }
        }

    }

    var lessons: LessonsModule

    // MARK: - Lifecycle

    static func live(userDefaultsClient: UserDefaultsClient) -> RozkladClient {
        RozkladClient(userDefaultsClient: userDefaultsClient)
    }

    private init(userDefaultsClient: UserDefaultsClient) {
        self.state = StateModule(userDefaultsClient: userDefaultsClient)
        self.lessons = LessonsModule(userDefaultsClient: userDefaultsClient)
    }
}
