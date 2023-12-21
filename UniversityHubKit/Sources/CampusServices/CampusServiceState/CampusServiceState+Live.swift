//
//  CampusServiceState+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Dependencies
import Combine
import GeneralServices
import CampusModels

extension CampusServiceState {
    static func live() -> CampusServiceState {
        @Dependency(\.keychainService) var keychainService
        @Dependency(\.userDefaultsService) var userDefaultsService
        
        let subject = CurrentValueSubject<State, Never>(.loggedOut)
        let commit: () -> Void = {
            if let campusUserInfo = userDefaultsService.get(for: .campusUserInfo) {
                subject.value = .loggedIn(campusUserInfo)
            } else {
                subject.value = .loggedOut
            }
        }
        commit()
        return CampusServiceState(
            stateStream: { AsyncStream(subject.values) },
            currentState: { subject.value },
            login: { clientValue in
                let userInfo = clientValue.value.userInfo
                let credentials = clientValue.value.credentials
                userDefaultsService.set(userInfo, for: .campusUserInfo)
                keychainService.set(credentials.username, for: .campusUsername)
                keychainService.set(credentials.password, for: .campusPassword)
                if clientValue.commitChanges {
                    commit()
                }
            },
            logout: { clientValue in
                userDefaultsService.remove(for: .campusUserInfo)
                try? keychainService.remove(for: .campusUsername)
                try? keychainService.remove(for: .campusPassword)
                if clientValue.commitChanges {
                    commit()
                }
            },
            commit: commit
        )
    }
}

extension UserDefaultKey {
    // TODO: Migration
    public static var campusUserInfo: UserDefaultKey<CampusUserInfo> {
        UserDefaultKey<CampusUserInfo>()
    }
}
