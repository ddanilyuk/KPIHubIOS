//
//  RozkladServiceState.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import Foundation

public struct RozkladServiceState {
    public enum State: Equatable {
        case selected(GroupResponse)
        case notSelected
    }

    public var stateStream: () -> AsyncStream<State>
    public var currentState: () -> State
    public var group: () -> GroupResponse?
    public var setState: (ClientValue<State>) -> Void
    public var commit: () -> Void
}
