//
//  AppDelegate.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import UIKit
import ComposableArchitecture
import Routes

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let store: StoreOf<App> = {
        Store(
            initialState: App.State(),
            reducer: App()
        )
    }()

    // MARK: - Store

    lazy var appDelegateStore = store.scope(
        state: \App.State.appDelegate,
        action: App.Action.appDelegate
    )
    lazy var viewStore: ViewStore<Void, AppDelegateReducer.Action> = ViewStore(appDelegateStore.stateless)

    // MARK: - Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Thread.sleep(forTimeInterval: 5)
        viewStore.send(.didFinishLaunching)
        return true
    }

}
