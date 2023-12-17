//
//  OtherSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

//import SwiftUI
//import ComposableArchitecture
//import DesignKit
//
//@ViewAction(for: ProfileHome.self)
//struct OtherSectionView: View {
//    let store: StoreOf<ProfileHome>
//    
//    init(store: StoreOf<ProfileHome>) {
//        self.store = store
//    }
//
//    var body: some View {
//        ProfileSectionView(
//            title: "Інше",
//            content: {
//                VStack(alignment: .leading, spacing: 16) {
//                    ProfileCellView(
//                        title: "",
//                        value: .text("Для розробників"),
//                        image: {
//                            Image(systemName: "terminal")
//                                .foregroundColor(.red.lighter(by: 0.9))
//                        },
//                        imageBackgroundColor: .red
//                    )
//                    .onTapGesture { send(.forDevelopersButtonTapped) }
//
//                    ProfileCellView(
//                        title: "Версія:",
//                        value: .text(store.completeAppVersion),
//                        image: {
//                            Image(systemName: "number")
//                                .foregroundColor(.blue.lighter(by: 0.9))
//                        },
//                        imageBackgroundColor: .blue
//                    )
//                }
//            }
//        )
//    }
//}
//
//
//// MARK: - Preview
//#Preview {
//    OtherSectionView(
//        store: Store(initialState: ProfileHome.State(completeAppVersion: "1.0 (1)")) {
//            ProfileHome()
//        }
//    )
//    .smallPreview
//    .padding(16)
//    // TODO: asset
////    .background(Color.screenBackground)
//}
