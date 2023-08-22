//
//  RozkladServiceState.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import Foundation

struct RozkladServiceState {
    enum State: Equatable {
        case selected(GroupResponse)
        case notSelected
    }

    let subject: CurrentValueSubject<State, Never>
    let group: () -> GroupResponse?
    let setState: (ClientValue<State>) -> Void
    let commit: () -> Void
}
