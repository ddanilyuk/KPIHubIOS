//
//  ForDevelopers.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import ComposableArchitecture
import Services

@Reducer
public struct ForDevelopers: Reducer {
    public struct State: Equatable { }
    
    public enum Action: Equatable, ViewAction {
        case view(View)
        
        public enum View: Equatable {
            case onAppear
        }
    }
    
    @Dependency(\.analyticsService) var analyticsService
    
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
