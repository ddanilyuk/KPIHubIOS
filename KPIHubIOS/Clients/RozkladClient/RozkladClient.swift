//
//  RozkladClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import IdentifiedCollections

final class RozkladClient {

    // MARK: - State

    enum State {
        case selected
        case notSelected
    }

    // MARK: - Properties

    private let userDefaultsClient: UserDefaultsClient

    // TODO: rename
    lazy var state: CurrentValueSubject<State, Never> = {
        if userDefaultsClient.get(for: .group) != nil {
            return .init(.selected)
        } else {
            return .init(.notSelected)
        }
    }()

    lazy var lessons: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never> = {
        if let lessons = userDefaultsClient.get(for: .lessons) {
            return .init(IdentifiedArray(uniqueElements: lessons))
        } else {
            return .init([])
        }
    }()

    // MARK: - Lifecycle

    static func live(userDefaultsClient: UserDefaultsClient) -> RozkladClient {
        RozkladClient(userDefaultsClient: userDefaultsClient)
    }

    private init(userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient
    }

    func logOut() {
        state.value = .notSelected
    }

    func updateState() {
        if userDefaultsClient.get(for: .group) != nil {
            state.value = .selected
        } else {
            state.value = .notSelected
        }
    }

    func updateLessons() {
        if let lessons = userDefaultsClient.get(for: .lessons) {
            self.lessons.value = IdentifiedArray(uniqueElements: lessons)
        } else {
            self.lessons.value = []
        }
    }

}
