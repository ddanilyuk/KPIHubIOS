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
            if let group = userDefaultsClient.get(for: .group) {
                return .init(.selected(group))
            } else {
                return .init(.notSelected)
            }
        }()

        func select(group: GroupResponse, commitChanges: Bool) {
            userDefaultsClient.set(group, for: .group)
            if commitChanges {
                commit()
            }
        }

        func deselect(commitChanges: Bool) {
            userDefaultsClient.remove(for: .group)
            if commitChanges {
                commit()
            }
        }

        func commit() {
            if let group = userDefaultsClient.get(for: .group) {
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
            if let lessons = userDefaultsClient.get(for: .lessons) {
                return .init(IdentifiedArray(uniqueElements: lessons))
            } else {
                return .init([])
            }
        }()

        func set(lessons: [Lesson], commitChanges: Bool) {
            userDefaultsClient.set(lessons, for: .lessons)
            if commitChanges {
                commit()
            }
        }

        func modify(with lesson: Lesson, commitChanges: Bool) {
            var lessons = IdentifiedArray(uniqueElements: userDefaultsClient.get(for: .lessons) ?? [])
            lessons[id: lesson.id] = lesson
            userDefaultsClient.set(lessons.elements, for: .lessons)
            if commitChanges {
                commit()
            }
        }

        func commit() {
            if let lessons = userDefaultsClient.get(for: .lessons) {
                subject.send(IdentifiedArray(uniqueElements: lessons))
            } else {
                subject.send([])
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
