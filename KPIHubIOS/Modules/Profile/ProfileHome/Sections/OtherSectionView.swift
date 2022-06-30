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
//        @BindableState var week: Bool
    }

    enum ViewAction {
//        case binding(BindingAction<ViewState>)
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
                }

            }
        )
    }

}

// MARK: - ViewState

//extension OtherSectionView.ViewState {
//
//    init(profileHomeState: ProfileHome.State) {
//        self._toggleWeek = profileHomeState.$toggleWeek
//    }
//}

// MARK: - ViewAction

//extension ProfileHome.Action {
//
//    init(otherSection: OtherSectionView.ViewAction) {
//        switch otherSection {
//        case .forDevelopers:
//            self = .routeAction(.forDevelopers)
//
//        case let .binding(action):
//
//            self = .binding(action.pullback(\.view))
//        }
//    }
//
//}

extension ProfileHome.State {
    var otherSectionView: OtherSectionView.ViewState {
        get {
            OtherSectionView.ViewState()
        }
        set {
//            let some = $toggleWeek
//            self.isLoading = newValue.week
//            toggleWeek = newValue.week
//            toggleWeek = newValue.toggleWeek
        }
    }
}

extension ProfileHome.Action {
    static func otherSectionView(_ viewAction: OtherSectionView.ViewAction) -> Self {
        switch viewAction {
//        case let .binding(action):
//            action.keyPath
//            switch action {
//            case .
//            }
//            return .binding(action.pullback(\.otherSectionView))

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
                        initialState: OtherSectionView.ViewState(),
                        reducer: Reducer.empty,
                        environment: Void()
                    )
                )
            )
            .smallPreview
            .padding(16)
            .background(Color.screenBackground)
        }
    }
}
