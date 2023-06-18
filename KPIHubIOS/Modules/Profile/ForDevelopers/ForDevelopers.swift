//
//  ForDevelopers.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import ComposableArchitecture

struct ForDevelopers: ReducerProtocol {

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
        var body: some ReducerProtocolOf<Self> {
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
    
    @Dependency(\.analyticsClient) var analyticsClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsClient.track(Event.Profile.forDevelopersAppeared)
                return .none
                
            case .presentSome:
                state.destination = .someFeature(SomeFeature.State())
                return .task {
                    try await Task.sleep(for: .seconds(5))
                    return .pushSome
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
