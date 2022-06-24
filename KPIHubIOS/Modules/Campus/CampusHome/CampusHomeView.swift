//
//  CampusHomeView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import SwiftUI

struct CampusHomeView: View {

    let store: Store<CampusHome.State, CampusHome.Action>

    let accentColor = Color(red: 250 / 255, green: 160 / 255, blue: 90 / 255)
    let backgroundColor = Color(red: 254 / 255, green: 244 / 255, blue: 235 / 255)

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack {
                    PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                        // do your stuff when pulled
                        viewStore.send(.refresh)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(backgroundColor)
                            .shadow(color: Color(red: 237 / 255, green: 107 / 255, blue: 7 / 255).opacity(0.15), radius: 12, x: 0, y: 6)

                        VStack {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(accentColor)

                                    Image(systemName: "graduationcap")
                                        .font(.system(.body).bold())
                                        .foregroundColor(.white)
                                }
                                .frame(width: 40, height: 40)

                                Text("Поточний контроль")
                                    .font(.system(.body).bold())

                                Spacer()
                            }

                            studySheetDescription(for: viewStore.state.studySheetState)
                                .font(.system(.callout))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 25)
                                .padding(.leading, 40 + 16)
                        }
                        .padding(16)
                    }
                    .onTapGesture {
                        viewStore.send(.studySheetTap)
                    }
                }
                .padding(24)
            }
            .coordinateSpace(name: "pullToRefresh")
            .onAppear {
                viewStore.send(.onAppear)
            }
            .background(Color.screenBackground)
            .navigationTitle("Кампус")
            .loadable(viewStore.binding(\.$isLoading))
        }

    }

    @ViewBuilder
    func studySheetDescription(for state: CampusClient.StudySheetModule.State) -> some View {
        switch state {
        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Завантаження")
            }

        case .notLoading:
            Text("Помилка")

        case .loaded:
            Text("Завантажено")
        }
    }

}

// MARK: - Preview

struct CampusHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampusHomeView(
                store: Store(
                    initialState: CampusHome.State(
                    ),
                    reducer: CampusHome.reducer,
                    environment: CampusHome.Environment(
                        apiClient: .failing,
                        userDefaultsClient: .live(),
                        campusClient: .live(apiClient: .failing, userDefaultsClient: .live(), keychainClient: KeychainClient.live())
                    )
                )
            )
        }
    }
}
