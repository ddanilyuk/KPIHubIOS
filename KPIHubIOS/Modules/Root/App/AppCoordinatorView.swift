//
//  AppCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct AppCoordinatorView: View {

    let store: StoreOf<App>

    var body: some View {
        Group {
            IfLetStore(
                store.scope(state: \.login, action: App.Action.login),
                then: LoginFlowCoordinatorView.init
            )
            IfLetStore(
                store.scope(state:  \.main, action: App.Action.main),
                then: MainTabCoordinatorView.init
            )
        }
    }

}
