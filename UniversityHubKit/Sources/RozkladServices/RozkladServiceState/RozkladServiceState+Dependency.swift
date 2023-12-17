//
//  RozkladServiceState+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies

extension DependencyValues {
    private enum RozkladClientStateKey: DependencyKey {
        static let testValue = RozkladServiceState()
        static let liveValue = RozkladServiceState.live()
    }
    
    public var rozkladServiceState: RozkladServiceState {
        get { self[RozkladClientStateKey.self] }
        set { self[RozkladClientStateKey.self] = newValue }
    }
}
