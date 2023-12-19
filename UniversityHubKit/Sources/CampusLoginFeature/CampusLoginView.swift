//
//  CampusLoginView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.06.2022.
//

import SwiftUI
import ComposableArchitecture
import DesignKit

@ViewAction(for: CampusLoginFeature.self)
public struct CampusLoginView: View {
    @Environment(\.designKit) var designKit
    @Bindable public var store: StoreOf<CampusLoginFeature>
    @FocusState private var focusedField: CampusLoginFeature.Field?
    
    public init(store: StoreOf<CampusLoginFeature>) {
        self.store = store
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    Text("Після входу буде відображатися поточний контроль")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.callout)
                        .padding()
                    
                    Spacer()
                    
                    VStack(spacing: 24) {
                        TextField("Логін", text: $store.username)
                            .focused($focusedField, equals: .username)
                            .onSubmit { focusedField = .password }
                            .keyboardType(.default)
                        
                        SecureField("Пароль", text: $store.password)
                            .focused($focusedField, equals: .password)
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            HStack {
                                Spacer()
                                Button("Готово") { focusedField = nil }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20.0) {
                        Button(
                            action: { send(.loginButtonTapped) },
                            label: { Text("Увійти") }
                        )
                        .buttonStyle(BigButtonStyle())
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .disabled(!store.loginButtonEnabled)
                    }
                    .padding(20)
                }
                .frame(minHeight: proxy.size.height)
            }
        }
        .navigationBarTitle("Кампус")
        .background(designKit.backgroundColor)
        .loadable($store.isLoading)
        .alert($store.scope(state: \.alert, action: \.alert))
        .synchronize($store.focusedField, $focusedField)
        .onAppear {
            send(.onAppear)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CampusLoginView(
            store: Store(initialState: CampusLoginFeature.State(mode: .onlyCampus)) {
                CampusLoginFeature()
            }
        )
    }
}
