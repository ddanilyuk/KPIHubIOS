//
//  RozkladClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine

final class RozkladClient {

    // MARK: - State

    enum State {
        case selected
        case notSelected
    }

    // MARK: - Properties

    private let userDefaultsClient: UserDefaultsClient

    lazy var state: CurrentValueSubject<State, Never> = {
        if userDefaultsClient.get(for: .group) != nil {
            return .init(.selected)
        } else {
            return .init(.notSelected)
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

}
