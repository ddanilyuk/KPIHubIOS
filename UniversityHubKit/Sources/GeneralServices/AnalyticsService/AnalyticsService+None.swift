//
//  AnalyticsService+Test.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation

extension AnalyticsService {
    public static func none() -> Self {
        AnalyticsService(
            track: { _ in },
            setUserProperty: { _ in }
        )
    }
}
