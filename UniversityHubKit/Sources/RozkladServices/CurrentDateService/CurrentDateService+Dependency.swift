//
//  CurrentDateService+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies

extension DependencyValues {
    private enum CurrentDateServiceKey: DependencyKey {
        static let liveValue = CurrentDateService.live()
        static let testValue = CurrentDateService()
    }
    
    public var currentDateService: CurrentDateService {
        get { self[CurrentDateServiceKey.self] }
        set { self[CurrentDateServiceKey.self] = newValue }
    }
}
