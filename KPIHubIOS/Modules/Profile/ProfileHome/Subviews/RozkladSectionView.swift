//
//  RozkladSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct RozkladSectionView: View {

    struct ViewState: Equatable {
        let updatedAt: Date?
        let rozkladState: RozkladClient.StateModule.State

        init(profileHomeState: ProfileHome.State) {
            updatedAt = profileHomeState.updatedDate
            rozkladState = profileHomeState.rozkladState
        }
    }

    enum ViewAction {
        case updateRozklad
        case changeGroup
        case selectGroup
    }

    let store: Store<ViewState, ViewAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ProfileSectionView(
                title: "Розклад",
                content: {
                    switch viewStore.rozkladState {
                    case let .selected(group):
                        selectedView(with: group)
                    case .notSelected:
                        notSelectedView
                    }
                }
            )
        }
    }

    func selectedView(with group: GroupResponse) -> some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 20) {

                ProfileCellView(
                    title: "Обрана группа:",
                    value: .text(group.name),
                    image: {
                        Image(systemName: "person.2")
                            .foregroundColor(Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255))
                    },
                    imageBackgroundColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                )

                ProfileCellView(
                    title: "Останнє оновлення:",
                    value: .date(viewStore.updatedAt),
                    image: {
                        Image(systemName: "clock")
                            .foregroundColor(.indigo.lighter(by: 0.9))
                    },
                    imageBackgroundColor: .indigo,
                    rightView: {
                        Button(
                            action: { viewStore.send(.updateRozklad) },
                            label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.red)
                                    .font(.headline.bold())
                            }
                        )
                    }
                )

                Divider()

                Button(
                    action: { viewStore.send(.changeGroup) },
                    label: {
                        Text("Змінити групу")
                            .font(.system(.body).bold())
                            .foregroundColor(.red)

                        Spacer()
                    }
                )
            }
        }
    }

    var notSelectedView: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 20) {

                Divider()

                Button(
                    action: { viewStore.send(.selectGroup) },
                    label: {
                        Text("Обрати групу")
                            .font(.system(.body).bold())
                            .foregroundColor(.green)

                        Spacer()
                    }
                )
            }
        }
    }

}

extension ProfileHome.Action {
    init(rozkladSection: RozkladSectionView.ViewAction) {
        switch rozkladSection {
        case .changeGroup:
            self = .changeGroupButtonTapped

        case .updateRozklad:
            self = .updateRozkladButtonTapped

        case .selectGroup:
            self = .selectGroup
        }
    }
}
