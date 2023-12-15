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

public struct AnalyticsService {
    public var track: (_ event: Event) -> Void
    public var setUserProperty: (_ userProperty: UserProperty) -> Void
}

extension AnalyticsService {
    static func none() -> Self {
        AnalyticsService(
            track: { _ in },
            setUserProperty: { _ in }
        )
    }
}
