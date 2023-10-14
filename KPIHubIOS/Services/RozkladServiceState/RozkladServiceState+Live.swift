//
//  RozkladServiceState+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Dependencies
import Combine
import CasePaths

extension RozkladServiceState {
    static func live() -> RozkladServiceState {
        @Dependency(\.userDefaultsService) var userDefaultsService
        
        let subject = CurrentValueSubject<State, Never>(.notSelected)
        let commit: () -> Void = {
            if let group = userDefaultsService.get(for: .groupResponse) {
                subject.send(.selected(group))
            } else {
                subject.send(.notSelected)
            }
        }
        commit()

        return RozkladServiceState(
            stateStream: { AsyncStream(subject.values) },
            currentState: { subject.value },
            group: {
                let groupResponsePath = /RozkladServiceState.State.selected
                return groupResponsePath.extract(from: subject.value)
            },
            setState: { clientValue in
                switch clientValue.value {
                case let .selected(group):
                    userDefaultsService.set(group, for: .groupResponse)
                case .notSelected:
                    userDefaultsService.remove(for: .groupResponse)
                }
                if clientValue.commitChanges {
                    commit()
                }
            },
            commit: commit
        )
    }
}
