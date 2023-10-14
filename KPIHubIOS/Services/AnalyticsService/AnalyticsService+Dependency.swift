//
//  AnalyticsService+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies

extension DependencyValues {
    private enum AnalyticsServiceKey: DependencyKey {
        static let liveValue = AnalyticsService.live()
        static let testValue = AnalyticsService.failing()
    }
    
    var analyticsService: AnalyticsService {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
}
