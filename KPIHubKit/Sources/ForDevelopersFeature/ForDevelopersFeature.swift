//
//  ForDevelopersFeature.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import ComposableArchitecture
import AnalyticsService

public struct ForDevelopersFeature: Reducer {
    public struct State: Equatable {
        public init() { }
    }
    
    public enum Action: Equatable {
        case view(View)
        
        public enum View: Equatable {
            case onAppear
        }
    }
    
    @Dependency(\.analyticsService) var analyticsService
    
    public init() { } 
    
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .view(.onAppear):
                analyticsService.track(Event.Profile.forDevelopersAppeared)
                return .none
            }
        }
    }
}
