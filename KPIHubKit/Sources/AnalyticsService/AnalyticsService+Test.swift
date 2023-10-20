//
//  AnalyticsService+Test.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import XCTestDynamicOverlay

extension AnalyticsService {
    static func failing() -> AnalyticsService {
        AnalyticsService(
           track: XCTUnimplemented("\(Self.self).track"),
           setUserProperty: XCTUnimplemented("\(Self.self).setUserProperty")
       )
    }
}
