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
