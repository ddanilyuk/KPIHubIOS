//
//  AnalyticsService.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import ComposableArchitecture
import Firebase
import FirebaseAnalytics
import XCTestDynamicOverlay

struct AnalyticsService {
    var track: (_ event: Event) -> Void
    var setUserProperty: (_ userProperty: UserProperty) -> Void
}

extension AnalyticsService {
    static func none() -> Self {
        AnalyticsService(
            track: { _ in },
            setUserProperty: { _ in }
        )
    }
}
