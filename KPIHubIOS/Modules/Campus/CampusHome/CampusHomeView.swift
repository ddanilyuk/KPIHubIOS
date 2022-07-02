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

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.orange.lighter(by: 0.85))
                        .shadow(color: .orange.opacity(0.15), radius: 12, x: 0, y: 6)

                    VStack {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.orange)

                                Image(systemName: "graduationcap")
                                    .font(.system(.body).bold())
                                    .foregroundColor(.orange.lighter(by: 0.9))
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
                .padding(24)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .background(Color.screenBackground)
                .listRowSeparator(.hidden, edges: .all)
            }
            .listStyle(.plain)
            .background(Color.screenBackground)
            .listRowSeparator(.hidden, edges: .all)
            .refreshable {
                viewStore.send(.refresh)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .navigationTitle("Кампус")
            .loadable(viewStore.binding(\.$isLoading))
        }
    }

    @ViewBuilder
    func studySheetDescription(for state: CampusClientStudySheet.State) -> some View {
        switch state {
        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Завантаження")
            }

        case .notLoading:
            Text("-")

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
                        userDefaultsClient: mockDependencies.userDefaults,
                        campusClient: .live(apiClient: .failing, userDefaultsClient: mockDependencies.userDefaults, keychainClient: KeychainClient.live())
                    )
                )
            )
        }
    }
}
