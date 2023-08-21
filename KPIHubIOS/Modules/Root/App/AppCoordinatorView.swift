//
//  AppCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct AppCoordinatorView: View {

    let store: StoreOf<AppFeature>

    var body: some View {
        Group {
            IfLetStore(
                store.scope(state: \.login, action: AppFeature.Action.login),
                then: LoginFlowCoordinatorView.init
            )
            IfLetStore(
                store.scope(state: \.main, action: AppFeature.Action.main),
                then: MainTabCoordinatorView.init
            )
        }
    }

}
