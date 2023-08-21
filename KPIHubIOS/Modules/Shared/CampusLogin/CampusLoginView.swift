//
//  CampusLoginView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct CampusLoginView: View {
    struct ViewState: Equatable {
        @BindingViewState var username: String
        @BindingViewState var password: String
        @BindingViewState var isLoading: Bool
        @BindingViewState var focusedField: CampusLoginFeature.Field?
        let loginButtonEnabled: Bool
        
        init(state: BindingViewStore<CampusLoginFeature.State>) {
            _username = state.$username
            _password = state.$password
            _isLoading = state.$isLoading
            _focusedField = state.$focusedField
            loginButtonEnabled = state.loginButtonEnabled
        }
    }
    
    private let store: StoreOf<CampusLoginFeature>
    @ObservedObject private var viewStore: ViewStore<ViewState, CampusLoginFeature.Action.View>
    @FocusState private var focusedField: CampusLoginFeature.Field?
    
    init(store: StoreOf<CampusLoginFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init, send: CampusLoginFeature.Action.view)
    }
    
    var body: some View {
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
                        TextField("Логін", text: viewStore.$username)
                            .focused($focusedField, equals: .username)
                            .onSubmit { focusedField = .password }
                            .keyboardType(.default)
                        
                        SecureField("Пароль", text: viewStore.$password)
                            .focused($focusedField, equals: .password)
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .disableAutocorrection(true)
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
                            action: { viewStore.send(.loginButtonTapped) },
                            label: { Text("Увійти") }
                        )
                        .buttonStyle(BigButtonStyle())
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .disabled(!viewStore.loginButtonEnabled)
                    }
                    .padding(20)
                }
                .frame(minHeight: proxy.size.height)
                
            }
        }
        .navigationBarTitle("Кампус")
        .background(Color.screenBackground)
        .loadable(viewStore.$isLoading)
        .alert(store: store.scope(state: \.$alert, action: CampusLoginFeature.Action.alert))
        .synchronize(viewStore.$focusedField, $focusedField)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

// MARK: - Preview

struct CampusLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampusLoginView(
                store: Store(initialState: CampusLoginFeature.State(mode: .onlyCampus)) {
                    CampusLoginFeature()
                }
            )
        }
    }
}
