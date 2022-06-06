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

    enum State {
        case selected
        case notSelected
    }

    lazy var stateSubject: CurrentValueSubject<State, Never> = {
        if userDefaultsClient.get(for: .group) != nil {
            return .init(.selected)
        } else {
            return .init(.notSelected)
        }
    }()

    func logOut() {
        stateSubject.value = .notSelected
    }

    func updateState() {
        if userDefaultsClient.get(for: .group) != nil {
            stateSubject.value = .selected
        } else {
            stateSubject.value = .notSelected
        }
    }

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
    }
}
