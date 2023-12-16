//
//  KPIHubIOSApp.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 19.05.2022.
//

import SwiftUI
import UniversityHubKit
import DesignKit

@main
struct KPIHubIOSApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: appDelegate.store)
                .accentColor(Color.orange)
                .environment(\.designKit, DesignKit.custom)
        }
    }
}

extension DesignKit {
    static let custom = DesignKit(
        primaryColor: .orange,
        backgroundColor: .white,
        currentLessonColor: .pink,
        nextLessonColor: .green
    )
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
