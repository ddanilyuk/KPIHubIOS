//
//  KPIHubIOSApp.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 19.05.2022.
//

import SwiftUI
import ComposableArchitecture
import Common

@main
struct KPIHubIOSApp: SwiftUI.App {
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

    // MARK: - Store

    private lazy var appDelegateStore = store.scope(
        state: \.appDelegate,
        action: { .appDelegate($0) }
    )

    // MARK: - Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        appDelegateStore.send(.didFinishLaunching)
        return true
    }
}
