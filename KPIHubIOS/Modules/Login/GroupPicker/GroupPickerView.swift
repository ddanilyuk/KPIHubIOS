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
                    Text(group.name)
                }
            }
            .searchable(
                text: viewStore.binding(\.$searchedText),
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Пошук")
            )
            .onAppear { viewStore.send(.onAppear) }
            .navigationTitle("Групи")
        }
    }

}
