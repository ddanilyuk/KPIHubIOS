//
//  AppDelegate.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 20.12.2023.
//

import ComposableArchitecture
import UIKit

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
                firebaseService.setup(bundle)
                return .none
            }
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
