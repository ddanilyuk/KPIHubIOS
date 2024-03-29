//
//  OtherSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct OtherSectionView: View {

    struct ViewState: Equatable {
        let completeAppVersion: String
    }

    enum ViewAction {
        case forDevelopers
    }

    @ObservedObject var viewStore: ViewStore<ViewState, ViewAction>

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
                    .onTapGesture { viewStore.send(.forDevelopers) }

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

// MARK: - ViewState

extension ProfileHome.State {

    var otherSectionView: OtherSectionView.ViewState {
        OtherSectionView.ViewState(
            completeAppVersion: completeAppVersion
        )
    }

}

// MARK: - ViewAction

extension ProfileHome.Action {

    static func otherSectionView(_ viewAction: OtherSectionView.ViewAction) -> Self {
        switch viewAction {
        case .forDevelopers:
            return .routeAction(.forDevelopers)
        }
    }
    
}

// MARK: - Preview

struct OtherSectionView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            OtherSectionView(
                viewStore: ViewStore(
                    Store(
                        initialState: OtherSectionView.ViewState(
                            completeAppVersion: "1.0 (1)"
                        ),
                        reducer: EmptyReducer()
                    )
                )
            )
            .smallPreview
            .padding(16)
            .background(Color.screenBackground)
        }
    }
}
