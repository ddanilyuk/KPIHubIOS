//
//  GroupPickerView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import DesignKit
import Services // TODO: Fix

@ViewAction(for: GroupPickerFeature.self)
public struct GroupPickerView: View {
    @Bindable public var store: StoreOf<GroupPickerFeature>
    @Environment(\.designKit) var designKit
    
    public init(store: StoreOf<GroupPickerFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.searchedGroups, id: \.id) { group in
                groupView(for: group)
            }
        }
        .scrollContentBackground(.hidden)
        .background(designKit.backgroundColor)
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
        .foregroundStyle(designKit.primaryColor)
    }
    
    @ViewBuilder
    private func groupView(for group: GroupResponse) -> some View {
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
