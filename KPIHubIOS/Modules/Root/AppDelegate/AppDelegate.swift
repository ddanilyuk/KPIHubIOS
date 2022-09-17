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
        let appConfiguration: AppConfiguration = .live(bundle: Bundle.main)
        let apiClient: APIClient = .live(
            router: rootRouter.baseURL(appConfiguration.apiURL)
        )
        let userDefaultsClient: UserDefaultsClientable = .live()
        let keychainClient: KeychainClientable = .live()
        let rozkladClientState: RozkladClientState = .live(
            userDefaultsClient: userDefaultsClient
        )
        let rozkladClientLessons: RozkladClientLessons = .live(
            userDefaultsClient: userDefaultsClient
        )
        let campusClientState: CampusClientState = .live(
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
        let campusClientStudySheet: CampusClientStudySheet = .live(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
        let currentDateClient: CurrentDateClient = .live(
            userDefaultsClient: userDefaultsClient,
            rozkladClientLessons: rozkladClientLessons
        )

        return Store(
            initialState: App.State(),
            reducer: App()
                .dependency(\.appConfiguration, appConfiguration)
                .dependency(\.apiClient, apiClient)
                .dependency(\.userDefaultsClient, userDefaultsClient)
                .dependency(\.keychainClient, keychainClient)
                .dependency(\.rozkladClientState, rozkladClientState)
                .dependency(\.rozkladClientLessons, rozkladClientLessons)
                .dependency(\.campusClientState, campusClientState)
                .dependency(\.campusClientStudySheet, campusClientStudySheet)
                .dependency(\.currentDateClient, currentDateClient)
        )
    }()

    // MARK: - Store

    lazy var appDelegateStore = store.scope(
        state: \App.State.appDelegate,
        action: App.Action.appDelegate
    )
    lazy var viewStore: ViewStoreOf<AppDelegateReducer> = ViewStore(appDelegateStore)

    // MARK: - Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        viewStore.send(.didFinishLaunching)
        return true
    }

}
