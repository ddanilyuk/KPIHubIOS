//
//  CampusServiceState+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies

extension DependencyValues {
    private enum CampusServiceStateKey: DependencyKey {
        static let testValue = CampusServiceState.mock()
        static let liveValue = CampusServiceState.live()
    }
    
    public var campusClientState: CampusServiceState {
        get { self[CampusServiceStateKey.self] }
        set { self[CampusServiceStateKey.self] = newValue }
    }
}
