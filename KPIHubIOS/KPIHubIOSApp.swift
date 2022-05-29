//
//  KPIHubIOSApp.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 19.05.2022.
//

import SwiftUI
import Routes

@main
struct KPIHubIOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: ViewModel(
                    apiClient: .live(router: rootRouter.baseURL("http://167.172.189.121:8080"))
                )
            )
        }
    }
}
