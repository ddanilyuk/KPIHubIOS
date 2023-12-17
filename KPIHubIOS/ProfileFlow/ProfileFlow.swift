//
//  ProfileFlow.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import ComposableArchitecture
import ProfileHomeFeature

@Reducer
struct ProfileFlow: Reducer {
    @ObservableState
    struct State: Equatable {
        var profileHome: ProfileHomeFeature.State
//        var path = StackState<Path.State>()
        
        init() {
            profileHome = ProfileHomeFeature.State(rozklad: .init(
                rozkladState: .selected(
                    GroupResponse(
                        id: UUID(),
                        name: "ІВ-82",
                        faculty: "ФІОТ"
                    )
                )
            ))
        }
    }
    
    enum Action: Equatable {
        case onSetup
        
        case profileHome(ProfileHomeFeature.Action)
//        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.profileHome, action: \.profileHome) {
            ProfileHomeFeature()
        }
        Reduce { state, action in
            switch action {
            case .onSetup:
                return .none
                
            case .profileHome:
                return .none
            }
        }
    }
}

import SwiftUI
import DesignKit
import Services // TODO: Fix

struct ProfileFlowView: View {
    let store: StoreOf<ProfileFlow>
    
    var body: some View {
        NavigationStack {
            ProfileHomeView(store: store.scope(state: \.profileHome, action: \.profileHome))
                .navigationTitle("Профіль КПІ")
        }
    }
}

struct ProfileHomeView: View {
    let store: StoreOf<ProfileHomeFeature>
    @Environment(\.designKit) var designKit

    var body: some View {
        ScrollView {
            ProfileHomeRozkladView(store: store.scope(state: \.rozklad, action: \.rozklad))
                .background(designKit.backgroundColor)
            
            Spacer()
        }
    }
}

@ViewAction(for: ProfileHomeRozkladFeature.self)
struct ProfileHomeRozkladView: View {
    @Bindable var store: StoreOf<ProfileHomeRozkladFeature>
    
    init(store: StoreOf<ProfileHomeRozkladFeature>) {
        self.store = store
    }

    var body: some View {
        ProfileSectionView(
            title: "Розклад",
            content: {
                switch store.rozkladState {
                case let .selected(group):
                    selectedView(with: group)

                case .notSelected:
                    notSelectedView
                }
            }
        )
        .onAppear {
            send(.onAppear)
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
    }

    func selectedView(with group: GroupResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            groupView(name: group.name)

            lastUpdatedAtView

            toggleWeekView

            Divider()

            Button(
                action: { send(.changeGroupButtonTapped) },
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
            value: .date(store.lessonsUpdatedAtDate),
            image: {
                Image(systemName: "clock")
                    .foregroundColor(.yellow.lighter(by: 0.9))
            },
            imageBackgroundColor: .yellow,
            rightView: {
                Button(
                    action: { send(.updateRozkladButtonTapped) },
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
                isOn: $store.toggleWeek,
                label: { Text("") }
            )
            .labelsHidden()
        }
    }

    var notSelectedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()

            Button(
                action: { send(.selectGroupButtonTapped) },
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
