//
//  CampusHomeView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import SwiftUI

struct CampusHomeView: View {
    struct ViewState: Equatable {
        let studySheetState: CampusServiceStudySheet.State
        @BindingViewState var isLoading: Bool
        
        init(state: BindingViewStore<CampusHome.State>) {
            studySheetState = state.studySheetState
            _isLoading = state.$isLoading
        }
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewStore: ViewStore<ViewState, CampusHome.Action.View>
    
    init(store: StoreOf<CampusHome>) {
        viewStore = ViewStore(store, observe: { ViewState(state: $0) }, send: { .view($0) })
    }

    var body: some View {
        List {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.orange.lighter(by: 0.85))
                    .if(colorScheme == .light) { view in
                        view
                            .shadow(color: .orange.opacity(0.15), radius: 12, x: 0, y: 6)
                    }

                VStack {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.orange)

                            Image(systemName: "graduationcap")
                                .font(.system(.body).bold())
                                .foregroundColor(.orange.lighter(by: colorScheme == .light ? 0.9 : 0.7))
                        }
                        .frame(width: 40, height: 40)

                        Text("Поточний контроль")
                            .font(.system(.body).bold())
                            .foregroundColor(.black)

                        Spacer()
                    }

                    studySheetDescription(for: viewStore.studySheetState)
                        .foregroundColor(.black)
                        .tint(.black)
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
        .loadable(viewStore.$isLoading)
    }

    @ViewBuilder
    func studySheetDescription(for state: CampusServiceStudySheet.State) -> some View {
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
#Preview {
    CampusHomeView(
        store: Store(initialState: CampusHome.State()) {
            CampusHome()
        }
    )
}
