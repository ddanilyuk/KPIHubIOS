//
//  GenericUniversityHubApp.swift
//  GenericUniversityHub
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import SwiftUI
import UniversityHubKit
import GroupPickerFeature
import RozkladFeature

@main
struct GenericUniversityHubApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: appDelegate.store)
                .accentColor(Color.orange)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store: StoreOf<AppFeature> = {
        Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    }()
    
    private lazy var appDelegateStore = store.scope(
        state: \.appDelegate,
        action: \.appDelegate
    )
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        appDelegateStore.send(.didFinishLaunching(Bundle.main))
        return true
    }
}

@Reducer
struct AppDelegateFeature: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable {
        case didFinishLaunching(Bundle)
    }
    
    @Dependency(\.firebaseService) var firebaseService
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case let .didFinishLaunching(bundle):
                // firebaseService.setup(bundle)
                return .none
            }
        }
    }
}


@Reducer
struct AppFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var appDelegate = AppDelegateFeature.State()
        var destination: Destination.State?
    }
    
    enum Action: Equatable {
        case appDelegate(AppDelegateFeature.Action)
        case destination(Destination.Action)
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
        
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
//                if userDefaultsService.get(for: .onboardingPassed) {
                state.destination = .main(RozkladFeature.State())
//                } else {
//                    state.destination = .onboarding(OnboardingFlow.State())
//                }
                return .none
                                
//            case .destination(.onboarding(.output(.done))):
//                state.destination = .main(MainFlow.State())
//                return .none
                
            case .appDelegate:
                return .none
                
            case .destination:
                return .none
            }
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateFeature()
        }
        core
            .ifLet(\.destination, action: \.destination) {
                Destination()
            }
    }
}

extension AppFeature {
    @Reducer
    struct Destination: Reducer {
        enum State: Equatable {
//            case onboarding(OnboardingFlow.State)
            case main(RozkladFeature.State)
        }
        
        enum Action: Equatable {
//            case onboarding(OnboardingFlow.Action)
            case main(RozkladFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
//            Scope(state: \.onboarding, action: \.onboarding) {
//                OnboardingFlow()
//            }
            Scope(state: \.main, action: \.main) {
                RozkladFeature()
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    var body: some View {
        switch store.destination {
//        case .groupPicker:
//            if let childStore = store.scope(
//                state: \.destination?.groupPicker,
//                action: \.destination.groupPicker
//            ) {
//                GroupPickerView(store: childStore)
//            }

        case .main:
            if let childStore = store.scope(
                state: \.destination?.main,
                action: \.destination.main
            ) {
                RozkladView(store: childStore) { cellStore in
                    RozkladLessonExtendedView(store: cellStore)
                }
            }
            
        case .none:
            EmptyView()
        }
    }
}
