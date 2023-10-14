//
//  ForDevelopers.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import ComposableArchitecture

struct ForDevelopers: Reducer {

    // MARK: - State

    struct State: Equatable {
        @PresentationState var destination: Destination.State?
    }
    
    struct Destination: Reducer {
        enum State: Equatable {
            case alert(AlertState<Action.Alert>)
            case someFeature(SomeFeature.State)
            case someFeaturePush(SomeFeature.State)

        }
        enum Action: Equatable {
            case alert(Alert)
            case someFeature(SomeFeature.Action)
            case someFeaturePush(SomeFeature.Action)
            
            enum Alert {
                case confirmDeletion
                case continueWithoutRecording
                case openSettings
            }
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.someFeature, action: /Action.someFeature) {
                SomeFeature()
            }
            Scope(state: /State.someFeaturePush, action: /Action.someFeaturePush) {
                SomeFeature()
            }
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case presentSome
        case pushSome
        case destination(PresentationAction<Destination.Action>)
    }

    // MARK: - Reducer
    
    @Dependency(\.analyticsService) var analyticsService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsService.track(Event.Profile.forDevelopersAppeared)
                return .none
                
            case .presentSome:
                state.destination = .someFeature(SomeFeature.State())
                return .run { send in
                    try await Task.sleep(for: .seconds(5))
                    await send(.pushSome)
                }
                
            case .pushSome:
                state.destination = .someFeaturePush(SomeFeature.State())
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

struct SomeFeature: Reducer {
    struct State: Equatable { }
    enum Action: Equatable {
        case dismiss
    }
    @Dependency(\.dismiss) var dismiss
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .none
                return .fireAndForget {
                    await self.dismiss()
                }
            }
        }
    }
}

import SwiftUI
struct SomeFeatureView: View {
    let store: StoreOf<SomeFeature>
    
    var body: some View {
        VStack {
            Text("SomeFeature")
            
            Button("Dismiss") {
                ViewStore(store, observe: { $0 })
                    .send(.dismiss)
            }
        }
    }
}
