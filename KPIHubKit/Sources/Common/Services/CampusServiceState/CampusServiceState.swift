//
//  CampusClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import Routes
import ComposableArchitecture
import KeychainAccess

struct CampusServiceState {
    enum State: Equatable {
        case loggedIn(CampusUserInfo)
        case loggedOut
    }

    struct LoginRequest {
        let credentials: CampusCredentials
        let userInfo: CampusUserInfo
    }

    var stateStream: () -> AsyncStream<State>
    var currentState: () -> State
    var login: (ClientValue<LoginRequest>) -> Void
    var logout: (ClientValue<Void>) -> Void
    var commit: () -> Void
}
