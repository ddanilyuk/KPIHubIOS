//
//  OtherSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import SwiftUI
import ComposableArchitecture
import Common

struct OtherSectionView: View {
    struct ViewState: Equatable {
        let completeAppVersion: String
        
        init(state: ProfileHome.State) {
            completeAppVersion = state.completeAppVersion
        }
    }
    
    @ObservedObject private var viewStore: ViewStore<ViewState, ProfileHome.Action.View>
    
    init(store: StoreOf<ProfileHome>) {
        viewStore = ViewStore(store, observe: ViewState.init, send: { .view($0) })
    }

    var body: some View {
        ProfileSectionView(
            title: "Інше",
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    ProfileCellView(
                        title: "",
                        value: .text("Для розробників"),
                        image: {
                            Image(systemName: "terminal")
                                .foregroundColor(.red.lighter(by: 0.9))
                        },
                        imageBackgroundColor: .red
                    )
                    .onTapGesture { viewStore.send(.forDevelopersButtonTapped) }

                    ProfileCellView(
                        title: "Версія:",
                        value: .text(viewStore.completeAppVersion),
                        image: {
                            Image(systemName: "number")
                                .foregroundColor(.blue.lighter(by: 0.9))
                        },
                        imageBackgroundColor: .blue
                    )
                }
            }
        )
    }
}


// MARK: - Preview
#Preview {
    OtherSectionView(
        store: Store(initialState: ProfileHome.State(completeAppVersion: "1.0 (1)")) {
            ProfileHome()
        }
    )
    .smallPreview
    .padding(16)
    .background(Color.screenBackground)
}
