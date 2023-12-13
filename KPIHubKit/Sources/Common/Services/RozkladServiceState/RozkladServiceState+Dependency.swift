//
//  RozkladServiceState+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies

extension DependencyValues {
    private enum RozkladClientStateKey: DependencyKey {
        static let testValue = RozkladServiceState.mock()
        static let liveValue = RozkladServiceState.live()
    }
    
    var rozkladServiceState: RozkladServiceState {
        get { self[RozkladClientStateKey.self] }
        set { self[RozkladClientStateKey.self] = newValue }
    }
}
