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
        let rozkladState: RozkladClientState.State
        @BindableState var week: Bool
    }

    enum ViewAction: BindableAction {
        case updateRozklad
        case changeGroup
        case selectGroup
        case binding(BindingAction<ViewState>)
    }

//    let store: Store<ViewState, ViewAction>
    @ObservedObject var viewStore: ViewStore<ViewState, ViewAction>

//    init(store: Store<ViewState, ViewAction>) {
//        self.store = store
//        self.viewStore = ViewStore(store)
//    }

    var body: some View {
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

    func selectedView(with group: GroupResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {

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

//            Divider( )

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.teal)

                    Image(systemName: "calendar")
                        .foregroundColor(Color.teal.lighter(by: 0.9))
                        .font(.system(.body))
                }
                .frame(width: 35, height: 35)

                VStack(alignment: .leading, spacing: 6) {

                    Text("Зміна тижня:")
                        .font(.system(.body))

                    Text("Іноді начання починається не з першого тижня. Ця змінна допоможе це виправити.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.caption))
                        .foregroundColor(Color.secondary)
                }

//                Spacer(minLength: 0)

                Toggle(
                    isOn: viewStore.binding(\.$week),
                    label: { Text("") }
                )
                .labelsHidden()
            }

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

    var notSelectedView: some View {
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

// MARK: - ViewState

//extension RozkladSectionView.ViewState {
//    init(profileHomeState: ProfileHome.State) {
//        updatedAt = profileHomeState.updatedDate
//        rozkladState = profileHomeState.rozkladState
//    }
//}
//
//// MARK: - ViewAction
//
//extension ProfileHome.Action {
//    init(rozkladSection: RozkladSectionView.ViewAction) {
//        switch rozkladSection {
//        case .changeGroup:
//            self = .changeGroupButtonTapped
//
//        case .updateRozklad:
//            self = .updateRozkladButtonTapped
//
//        case .selectGroup:
//            self = .selectGroup
//        }
//    }
//}



extension ProfileHome.State {
    var rozkladSectionView: RozkladSectionView.ViewState {
        get {
            RozkladSectionView.ViewState(
                updatedAt: self.updatedDate,
                rozkladState: self.rozkladState,
                week: self.toggleWeek
            )
        }
        set {
            toggleWeek = newValue.week
        }
    }
}

extension ProfileHome.Action {
    static func rozkladSectionView(_ viewAction: RozkladSectionView.ViewAction) -> Self {
        switch viewAction {
        case .changeGroup:
            return .changeGroupButtonTapped

        case .updateRozklad:
            return .updateRozkladButtonTapped

        case .selectGroup:
            return .selectGroup

        case let .binding(action):
            return .binding(action.pullback(\.rozkladSectionView))
        }
    }
}

// MARK: - Preview

struct RozkladSectionView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            RozkladSectionView(
                viewStore: ViewStore(Store(
                    initialState: RozkladSectionView.ViewState(
                        updatedAt: Date(),
                        rozkladState: .notSelected,
                        week: true
                    ),
                    reducer: Reducer.empty,
                    environment: Void()
                ))
            )
            .smallPreview
            .padding(16)
            .background(Color.screenBackground)

            RozkladSectionView(
                viewStore: ViewStore(Store(
                    initialState: RozkladSectionView.ViewState(
                        updatedAt: Date(),
                        rozkladState: .selected(
                            GroupResponse(
                                id: UUID(),
                                name: "ІВ-82"
                            )
                        ),
                        week: false
                    ),
                    reducer: Reducer.empty,
                    environment: Void()
                ))
            )
            .smallPreview
            .padding(16)
            .background(Color.screenBackground)

        }
    }
}
