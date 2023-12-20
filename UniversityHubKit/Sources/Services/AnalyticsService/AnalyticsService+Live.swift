//
//  AnalyticsService+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import FirebaseAnalytics

extension AnalyticsService {
    static func live() -> AnalyticsService {
        AnalyticsService(
            track: { event in
                Analytics.logEvent(event.name, parameters: event.parameters)
            },
            setUserProperty: { userProperty in
                Analytics.setUserProperty(userProperty.value, forName: userProperty.name)
            }
        )
    }
}
