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

    class StateModule {

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

    // MARK: - State

//    enum State: Equatable {
//        case selected(GroupResponse)
//        case notSelected
//    }
//
//    lazy var stateSubject: CurrentValueSubject<State, Never> = {
//        if let group = userDefaultsClient.get(for: .group) {
//            return .init(.selected(group))
//        } else {
//            return .init(.notSelected)
//        }
//    }()
//
//    func set(group: GroupResponse, withUpdating: Bool = true) {
//        userDefaultsClient.set(group, for: .group)
//        if withUpdating {
//            updateState()
//        }
//    }
//
//    func logOut() {
//        stateSubject.value = .notSelected
//        userDefaultsClient.remove(for: .group)
//    }
//
//    func updateState() {
//        if let group = userDefaultsClient.get(for: .group) {
//            stateSubject.value = .selected(group)
//        } else {
//            stateSubject.value = .notSelected
//        }
//    }

    // MARK: - Lessons

    lazy var lessonsSubject: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never> = {
        if let lessons = userDefaultsClient.get(for: .lessons) {
            return .init(IdentifiedArray(uniqueElements: lessons))
        } else {
            return .init([])
        }
    }()

    func set(lessons: [Lesson]) {
        userDefaultsClient.set(lessons, for: .lessons)
        updateLessons()
    }

    func updateLessons() {
        if let lessons = userDefaultsClient.get(for: .lessons) {
            self.lessonsSubject.value = IdentifiedArray(uniqueElements: lessons)
        } else {
            self.lessonsSubject.value = []
        }
    }

    func modified(lesson: Lesson) {
        var lessons = IdentifiedArray(uniqueElements: userDefaultsClient.get(for: .lessons) ?? [])
        lessons[id: lesson.id] = lesson
        userDefaultsClient.set(lessons.elements, for: .lessons)
        lessonsSubject.value = lessons
    }

    // MARK: - Lifecycle

    static func live(userDefaultsClient: UserDefaultsClient) -> RozkladClient {
        RozkladClient(userDefaultsClient: userDefaultsClient)
    }

    private let userDefaultsClient: UserDefaultsClient

    private init(userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient
        self.state = StateModule(userDefaultsClient: userDefaultsClient)
    }
}
