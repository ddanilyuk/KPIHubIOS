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
import GeneralServices

extension RozkladServiceState {
    static func live() -> RozkladServiceState {
        let liveHelper = LiveHelper()
        return RozkladServiceState(
            stateStream: liveHelper.stateStream,
            currentState: liveHelper.currentState,
            group: liveHelper.group,
            setState: liveHelper.setState,
            commit: liveHelper.commit,
            loadGroups: liveHelper.loadGroups
        )
    }
}

private extension RozkladServiceState {
    struct LiveHelper {
        @Dependency(\.userDefaultsService) var userDefaultsService
        @Dependency(\.apiService) var apiService
        private let subject = CurrentValueSubject<State, Never>(.notSelected)
        
        init() {
            commit()
        }
        
        func stateStream() -> AsyncStream<State> {
            AsyncStream(subject.values)
        }
        
        func currentState() -> State {
            subject.value
        }
        
        func group() -> GroupResponse? {
            // TODO: Fox
            let groupResponsePath = /RozkladServiceState.State.selected
            return groupResponsePath.extract(from: subject.value)
        }
        
        func setState(clientValue: ClientValue<State>) {
            switch clientValue.value {
            case let .selected(group):
                userDefaultsService.set(group, for: .groupResponse)

            case .notSelected:
                userDefaultsService.remove(for: .groupResponse)
            }
            if clientValue.commitChanges {
                commit()
            }
        }
        
        func commit() {
            if let group = userDefaultsService.get(for: .groupResponse) {
                subject.send(.selected(group))
            } else {
                subject.send(.notSelected)
            }
        }
        
        func loadGroups() async throws -> [GroupResponse] {
            try await apiService
                .decodedResponse(
                    for: .api(.groups(.all)),
                    as: GroupsResponse.self
                )
                .value.groups
        }
    }
}
