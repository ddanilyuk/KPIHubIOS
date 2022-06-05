//
//  TCARouter+EmptyScreen.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import SwiftUI

struct EmptyScreen {
    struct State: Equatable {

    }

    enum Action: Equatable {

    }
}

struct EmptyScreenView: View {

    let store: Store<EmptyScreen.State, EmptyScreen.Action>

    var body: some View {
        Color.clear
    }
}
