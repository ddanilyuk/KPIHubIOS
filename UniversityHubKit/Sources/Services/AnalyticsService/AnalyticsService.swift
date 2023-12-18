//
//  AnalyticsService.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import DependenciesMacros

@DependencyClient
public struct AnalyticsService {
    public var track: (_ event: Event) -> Void
    public var setUserProperty: (_ userProperty: UserProperty) -> Void
}
