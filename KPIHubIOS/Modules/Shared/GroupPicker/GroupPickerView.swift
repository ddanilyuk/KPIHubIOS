//
//  GroupPickerView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct GroupPickerView: View {
    struct ViewState: Equatable {
        @BindingViewState var isLoading: Bool
        @BindingViewState var searchedText: String
        let searchedGroups: [GroupResponse]
        
        init(state: BindingViewStore<GroupPickerFeature.State>) {
            _isLoading = state.$isLoading
            _searchedText = state.$searchedText
            searchedGroups = state.searchedGroups
        }
    }
    
    private let store: StoreOf<GroupPickerFeature>
    @ObservedObject private var viewStore: ViewStore<ViewState, GroupPickerFeature.Action.View>
    
    init(store: StoreOf<GroupPickerFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init, send: GroupPickerFeature.Action.view)
    }

    var body: some View {
        List {
            ForEach(viewStore.searchedGroups, id: \.id) { group in
                ZStack {
                    VStack {
                        Text(group.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(group.faculty ?? "-")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.endEditing()
                    viewStore.send(.groupSelected(group))
                }
            }
        }
        .refreshable {
            viewStore.send(.refresh)
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .navigationTitle("Оберіть групу")
        .loadable(viewStore.$isLoading)
        .alert(store: store.scope(state: \.$alert, action: GroupPickerFeature.Action.alert))
        .searchable(
            text: viewStore.$searchedText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Пошук")
        )
    }
}
