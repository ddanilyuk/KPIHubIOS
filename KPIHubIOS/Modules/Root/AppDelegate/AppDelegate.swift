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
        Store(initialState: App.State()) {
            App()
        }
    }()

    // MARK: - Store

    lazy var appDelegateStore = store.scope(
        state: \.appDelegate,
        action: App.Action.appDelegate
    )

    // MARK: - Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Thread.sleep(forTimeInterval: 5)
        appDelegateStore.send(.didFinishLaunching)
        return true
    }

}
