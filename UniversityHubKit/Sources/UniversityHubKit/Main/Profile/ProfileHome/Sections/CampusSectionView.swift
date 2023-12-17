//
//  CampusSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

//import SwiftUI
//import ComposableArchitecture
//import Services
//import DesignKit
//
//@ViewAction(for: ProfileHome.self)
//struct CampusSectionView: View {
//    let store: StoreOf<ProfileHome>
//    
//    init(store: StoreOf<ProfileHome>) {
//        self.store = store
//    }
//
//    var body: some View {
//        ProfileSectionView(
//            title: "Кампус",
//            content: {
//                switch store.campusState {
//                case .loggedIn:
//                    loggedInView
//
//                case .loggedOut:
//                    loggedOutView
//                }
//            }
//        )
//    }
//
//    private var loggedInView: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            ProfileCellView(
//                title: "Ім'я:",
//                value: .text(store.fullName),
//                image: {
//                    Image(systemName: "person")
//                        .foregroundColor(Color.mint.lighter(by: 0.9))
//                },
//                imageBackgroundColor: Color.mint
//            )
//
//            ProfileCellView(
//                title: "Кафедра:",
//                value: .text(store.cathedra),
//                image: {
//                    Image(systemName: "graduationcap")
//                        .foregroundColor(Color.cyan.lighter(by: 0.9))
//                },
//                imageBackgroundColor: Color.cyan
//            )
//
//            Divider()
//
//            Button(
//                action: { send(.logoutCampusButtonTapped) },
//                label: {
//                    Text("Вийти з аккаунту")
//                        .font(.system(.body).bold())
//                        .foregroundColor(.red)
//
//                    Spacer()
//                }
//            )
//        }
//    }
//
//    private var loggedOutView: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Divider()
//
//            Button(
//                action: { send(.loginCampusButtonTapped) },
//                label: {
//                    Text("Увійти у кампус")
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
//extension ProfileHome.State {
//    // TODO: Fix
//    var fullName: String {
//        let campusUserInfoPath = /CampusServiceState.State.loggedIn
//        let campusUserInfo = campusUserInfoPath.extract(from: campusState)
//        return campusUserInfo?.fullName ?? "-"
//    }
//    
//    // TODO: Fix
//    var cathedra: String {
//        let campusUserInfoPath = /CampusServiceState.State.loggedIn
//        let campusUserInfo = campusUserInfoPath.extract(from: campusState)
//        return campusUserInfo?.subdivision.first?.name ?? "-"
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    CampusSectionView(
//        store: Store(
//            initialState: ProfileHome.State(campusState: .loggedIn(CampusUserInfo.mock))
//        ) {
//            ProfileHome()
//        }
//    )
//    .smallPreview
//    .padding(16)
//    // TODO: assets
////    .background(Color.screenBackground)
//}
//
//#Preview {
//    CampusSectionView(
//        store: Store(
//            initialState: ProfileHome.State(campusState: .loggedOut)
//        ) {
//            ProfileHome()
//        }
//    )
//    .smallPreview
//    .padding(16)
//    // TODO: assets
////    .background(Color.screenBackground)
//}
