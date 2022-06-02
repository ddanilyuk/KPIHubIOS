//
//  KPIHubIOSApp.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 19.05.2022.
//

import SwiftUI
import Routes
import ComposableArchitecture

@main
struct KPIHubIOSApp: SwiftUI.App {

    static let store = Store<App.State, App.Action>(
        initialState: App.State(),
        reducer: App.reducer,
        environment: App.Environment.live
    )

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(store: KPIHubIOSApp.store)
        }
    }

}
