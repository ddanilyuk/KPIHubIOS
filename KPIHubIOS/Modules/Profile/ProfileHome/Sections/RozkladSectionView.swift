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
        @BindableState var toggleWeek: Bool
    }

    enum ViewAction: BindableAction {
        case updateRozklad
        case changeGroup
        case selectGroup
        case binding(BindingAction<ViewState>)
    }

    @ObservedObject var viewStore: ViewStore<ViewState, ViewAction>

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

            groupView(name: group.name)

            lastUpdatedAtView

            toggleWeekView

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

    func groupView(name: String) -> some View {
        ProfileCellView(
            title: "Обрана группа:",
            value: .text(name),
            image: {
                Image(systemName: "person.2")
                    .foregroundColor(Color.indigo.lighter(by: 0.9))
            },
            imageBackgroundColor: Color.indigo
        )
    }

    var lastUpdatedAtView: some View {
        ProfileCellView(
            title: "Останнє оновлення:",
            value: .date(viewStore.updatedAt),
            image: {
                Image(systemName: "clock")
                    .foregroundColor(.yellow.lighter(by: 0.9))
            },
            imageBackgroundColor: .yellow,
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
    }

    var toggleWeekView: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.cyan)

                Image(systemName: "calendar")
                    .foregroundColor(Color.cyan.lighter(by: 0.9))
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

            Toggle(
                isOn: viewStore.binding(\.$toggleWeek),
                label: { Text("") }
            )
            .labelsHidden()
        }
    }

    var notSelectedView: some View {
        VStack(alignment: .leading, spacing: 16) {

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

extension ProfileHome.State {

    var rozkladSectionView: RozkladSectionView.ViewState {
        get {
            RozkladSectionView.ViewState(
                updatedAt: self.lessonsUpdatedAtDate,
                rozkladState: self.rozkladState,
                toggleWeek: self.toggleWeek
            )
        }
        set {
            toggleWeek = newValue.toggleWeek
        }
    }

}

// MARK: - ViewAction

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
                        toggleWeek: true
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
                        toggleWeek: false
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
