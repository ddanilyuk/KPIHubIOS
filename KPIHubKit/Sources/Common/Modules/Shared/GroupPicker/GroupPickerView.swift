//
//  GroupPickerView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

@ViewAction(for: GroupPickerFeature.self)
struct GroupPickerView: View {
    @Bindable var store: StoreOf<GroupPickerFeature>
    
    init(store: StoreOf<GroupPickerFeature>) {
        self.store = store
    }

    var body: some View {
        List {
            ForEach(store.searchedGroups, id: \.id) { group in
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
                    send(.groupSelected(group))
                }
            }
        }
        .refreshable {
            send(.refresh)
        }
        .onAppear {
            send(.onAppear)
        }
        .navigationTitle("Оберіть групу")
        .loadable($store.isLoading)
        .alert($store.scope(state: \.alert, action: \.alert))
        .searchable(
            text: $store.searchedText,
            isPresented: $store.searchPresented,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Пошук")
        )
    }
}
