//
//  CampusServiceState+Mock.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Combine

extension CampusServiceState {
    static func mock() -> CampusServiceState {
        CampusServiceState(
            stateStream: { .never },
            currentState: { .loggedIn(CampusUserInfo.mock) },
            login: { _ in },
            logout: { _ in },
            commit: { }
        )
    }
}
