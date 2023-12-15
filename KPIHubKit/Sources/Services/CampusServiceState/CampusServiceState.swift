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

public struct CampusServiceState {
    public enum State: Equatable {
        case loggedIn(CampusUserInfo)
        case loggedOut
    }

    public struct LoginRequest {
        let credentials: CampusCredentials
        let userInfo: CampusUserInfo
        
        public init(credentials: CampusCredentials, userInfo: CampusUserInfo) {
            self.credentials = credentials
            self.userInfo = userInfo
        }
    }

    public var stateStream: () -> AsyncStream<State>
    public var currentState: () -> State
    public var login: (ClientValue<LoginRequest>) -> Void
    public var logout: (ClientValue<Void>) -> Void
    public var commit: () -> Void
}
