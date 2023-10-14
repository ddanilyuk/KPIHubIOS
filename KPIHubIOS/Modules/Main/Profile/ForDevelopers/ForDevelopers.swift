//
//  ForDevelopers.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import ComposableArchitecture

struct ForDevelopers: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable {
        case view(View)
        
        enum View: Equatable {
            case onAppear
        }
    }
    
    @Dependency(\.analyticsService) var analyticsService
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .view(.onAppear):
                analyticsService.track(Event.Profile.forDevelopersAppeared)
                return .none
            }
        }
    }
}
