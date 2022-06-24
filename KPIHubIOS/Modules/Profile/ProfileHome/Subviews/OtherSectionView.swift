//
//  OtherSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct OtherSectionView: View {

    struct ViewState: Equatable { }

    enum ViewAction {
        case forDevelopers
    }

    let store: Store<ViewState, ViewAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ProfileSectionView(
                title: "Інше",
                content: {
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
                }
            )
        }
    }

}

// MARK: - ViewAction

extension ProfileHome.Action {

    init(otherSection: OtherSectionView.ViewAction) {
        switch otherSection {
        case .forDevelopers:
            self = .routeAction(.forDevelopers)
        }
    }

}

// MARK: - Preview

struct OtherSectionView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            OtherSectionView(
                store: Store(
                    initialState: OtherSectionView.ViewState(),
                    reducer: Reducer.empty,
                    environment: Void()
                )
            )
            .smallPreview
            .padding(16)
            .background(Color.screenBackground)
        }
    }
}
