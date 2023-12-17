//
//  RozkladSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

//import SwiftUI
//import ComposableArchitecture
//import Services // TODO: ?
//import DesignKit
//
//@ViewAction(for: ProfileHome.self)
//struct RozkladSectionView: View {
//    @Bindable var store: StoreOf<ProfileHome>
//    
//    init(store: StoreOf<ProfileHome>) {
//        self.store = store
//    }
//
//    var body: some View {
//        ProfileSectionView(
//            title: "Розклад",
//            content: {
//                switch store.rozkladState {
//                case let .selected(group):
//                    selectedView(with: group)
//
//                case .notSelected:
//                    notSelectedView
//                }
//            }
//        )
//    }
//
//    func selectedView(with group: GroupResponse) -> some View {
//        VStack(alignment: .leading, spacing: 16) {
//            groupView(name: group.name)
//
//            lastUpdatedAtView
//
//            toggleWeekView
//
//            Divider()
//
//            Button(
//                action: { send(.changeGroupButtonTapped) },
//                label: {
//                    Text("Змінити групу")
//                        .font(.system(.body).bold())
//                        .foregroundColor(.red)
//
//                    Spacer()
//                }
//            )
//        }
//    }
//
//    func groupView(name: String) -> some View {
//        ProfileCellView(
//            title: "Обрана группа:",
//            value: .text(name),
//            image: {
//                Image(systemName: "person.2")
//                    .foregroundColor(Color.indigo.lighter(by: 0.9))
//            },
//            imageBackgroundColor: Color.indigo
//        )
//    }
//
//    var lastUpdatedAtView: some View {
//        ProfileCellView(
//            title: "Останнє оновлення:",
//            value: .date(store.lessonsUpdatedAtDate),
//            image: {
//                Image(systemName: "clock")
//                    .foregroundColor(.yellow.lighter(by: 0.9))
//            },
//            imageBackgroundColor: .yellow,
//            rightView: {
//                Button(
//                    action: { send(.updateRozkladButtonTapped) },
//                    label: {
//                        Image(systemName: "arrow.triangle.2.circlepath")
//                            .foregroundColor(.red)
//                            .font(.headline.bold())
//                    }
//                )
//            }
//        )
//    }
//
//    var toggleWeekView: some View {
//        HStack(spacing: 16) {
//            ZStack {
//                Circle()
//                    .fill(Color.cyan)
//
//                Image(systemName: "calendar")
//                    .foregroundColor(Color.cyan.lighter(by: 0.9))
//                    .font(.system(.body))
//            }
//            .frame(width: 35, height: 35)
//
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Зміна тижня:")
//                    .font(.system(.body))
//
//                Text("Іноді начання починається не з першого тижня. Ця змінна допоможе це виправити.")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .font(.system(.caption))
//                    .foregroundColor(Color.secondary)
//            }
//
//            Toggle(
//                isOn: $store.toggleWeek,
//                label: { Text("") }
//            )
//            .labelsHidden()
//        }
//    }
//
//    var notSelectedView: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Divider()
//
//            Button(
//                action: { send(.selectGroupButtonTapped) },
//                label: {
//                    Text("Обрати групу")
//                        .font(.system(.body).bold())
//                        .foregroundColor(.green)
//
//                    Spacer()
//                }
//            )
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    RozkladSectionView(
//        store: Store(initialState: ProfileHome.State(
//            rozkladState: .notSelected,
//            lessonsUpdatedAtDate: Date(),
//            toggleWeek: true
//        )) {
//            ProfileHome()
//        }
//    )
//    .smallPreview
//    .padding(16)
//    // TODO: asset
////    .background(Color.screenBackground)
//}
//
//#Preview {
//    RozkladSectionView(
//        store: Store(initialState: ProfileHome.State(
//            rozkladState: .selected(
//                GroupResponse(
//                    id: UUID(),
//                    name: "ІВ-82",
//                    faculty: "ФІОТ"
//                )
//            ),
//            lessonsUpdatedAtDate: Date(),
//            toggleWeek: false
//        )) {
//            ProfileHome()
//        }
//    )
//    .smallPreview
//    .padding(16)
//    // TODO: asset
////    .background(Color.screenBackground)
//}
