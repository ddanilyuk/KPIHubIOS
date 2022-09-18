//
//  CampusLoginView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct CampusLoginView: View {

    let store: StoreOf<CampusLogin>
    @FocusState private var focusedField: CampusLogin.State.Field?

    var body: some View {
        WithViewStore(store) { viewStore in
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
                            TextField("Логін", text: viewStore.binding(\.$username))
                                .focused($focusedField, equals: .username)
                                .onSubmit { focusedField = .password }
                                .keyboardType(.default)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)

                            SecureField("Пароль", text: viewStore.binding(\.$password))
                                .focused($focusedField, equals: .password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
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
                                action: { viewStore.send(.login) },
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
            .loadable(viewStore.binding(\.$isLoading))
            .alert(
                self.store.scope(state: \.alert),
                dismiss: .dismissAlert
            )
            .synchronize(viewStore.binding(\.$focusedField), self.$focusedField)
        }
    }
}

// MARK: - Preview

struct CampusLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampusLoginView(
                store: Store(
                    initialState: CampusLogin.State(mode: .onlyCampus),
                    reducer: CampusLogin()
                )
            )
        }
    }
}
