//
//  GroupPickerView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct GroupPickerView: View {

    let store: Store<GroupPicker.State, GroupPicker.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
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
            .loadable(viewStore.binding(\.$isLoading))
            .alert(
                self.store.scope(state: \.alert),
                dismiss: .dismissAlert
            )
            .searchable(
                text: viewStore.binding(\.$searchedText),
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Пошук")
            )
        }
    }

}
