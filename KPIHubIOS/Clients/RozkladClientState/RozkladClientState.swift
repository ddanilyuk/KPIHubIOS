//
//  RozkladClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import IdentifiedCollections
import Foundation
import CasePaths
import Dependencies

private enum RozkladClientStateKey: TestDependencyKey {
    static let testValue = RozkladClientState.mock()
}

extension RozkladClientStateKey: DependencyKey {
    static let liveValue = RozkladClientState.live(
        userDefaultsClient: DependencyValues.current.userDefaultsClient
    )
}

extension DependencyValues {
    var rozkladClientState: RozkladClientState {
        get { self[RozkladClientStateKey.self] }
        set { self[RozkladClientStateKey.self] = newValue }
    }
}

struct RozkladClientState {

    enum State: Equatable {
        case selected(GroupResponse)
        case notSelected
    }

    let subject: CurrentValueSubject<State, Never>
    let group: () -> GroupResponse?
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
            group: {
                let groupResponsePath = /RozkladClientState.State.selected
                return groupResponsePath.extract(from: subject.value)
            },
            setState: { clientValue in
                switch clientValue.value {
                case let .selected(group):
                    userDefaultsClient.set(group, for: .groupResponse)
                case .notSelected:
                    userDefaultsClient.remove(for: .groupResponse)
                }
                if clientValue.commitChanges {
                    commit()
                }
            },
            commit: commit
        )
    }

    static func mock() -> RozkladClientState {
        let group = GroupResponse(id: UUID(), name: "ІВ-82", faculty: "ФІОТ")
        return RozkladClientState(
            subject: CurrentValueSubject<State, Never>(
                .selected(group)
            ),
            group: { group },
            setState: { _ in },
            commit: { }
        )
    }

}
