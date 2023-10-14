//
//  RozkladServiceState.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import Foundation
import Common

struct RozkladServiceState {
    enum State: Equatable {
        case selected(GroupResponse)
        case notSelected
    }

    var stateStream: () -> AsyncStream<State>
    var currentState: () -> State
    var group: () -> GroupResponse?
    var setState: (ClientValue<State>) -> Void
    var commit: () -> Void
}
