//
//  RozkladServiceState.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import DependenciesMacros
import GeneralServices

@DependencyClient
public struct RozkladServiceState {
    public enum State: Equatable {
        case selected(GroupResponse)
        case notSelected
    }

    public var stateStream: () -> AsyncStream<State> = { .never }
    public var currentState: () -> State = { .notSelected }
    public var group: () -> GroupResponse?
    public var setState: (ClientValue<State>) -> Void
    public var commit: () -> Void
    public var loadGroups: () async throws -> [GroupResponse]
}
