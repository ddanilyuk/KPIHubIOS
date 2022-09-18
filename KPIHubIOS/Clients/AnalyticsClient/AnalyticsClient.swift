//
//  AnalyticsClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import ComposableArchitecture
import Firebase
import FirebaseAnalytics
import XCTestDynamicOverlay

struct AnalyticsClient {
    var track: (_ event: Event) -> Void
    var setUserProperty: (_ userProperty: UserProperty) -> Void
}

extension AnalyticsClient {
    
    static func live() -> Self {
        Self(
            track: { event in
                Analytics.logEvent(event.name, parameters: event.parameters)
            },
            setUserProperty: { userProperty in
                Analytics.setUserProperty(userProperty.value, forName: userProperty.name)
            }
        )
    }
    
    static var failing = Self(
        track: XCTUnimplemented("\(Self.self).track"),
        setUserProperty: XCTUnimplemented("\(Self.self).setUserProperty")
    )
    
}

private enum AnalyticsClientKey: DependencyKey {
    static let liveValue = AnalyticsClient.live()
    static let testValue = AnalyticsClient.failing
}

extension DependencyValues {
    var analyticsClient: AnalyticsClient {
        get { self[AnalyticsClientKey.self] }
        set { self[AnalyticsClientKey.self] = newValue }
    }
}
