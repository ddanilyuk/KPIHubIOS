//
//  AppDelegate.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import UIKit
import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Store

    lazy var appDelegateStore = KPIHubIOSApp.store.scope(
        state: \App.State.appDelegate,
        action: App.Action.appDelegate
    )
    lazy var viewStore: ViewStore<State, Action> = ViewStore(appDelegateStore)

    // MARK: - Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        viewStore.send(.didFinishLaunching)
        return true
    }

}
