//
//  CampusLoginView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct CampusLoginView: View {

    private enum Field: Int, CaseIterable {
        case username
        case password
    }

    let store: Store<CampusLogin.State, CampusLogin.Action>
    @FocusState private var focusedField: Field?

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                VStack(spacing: 24) {
                    TextField("Username", text: viewStore.binding(\.$username))
                        .focused($focusedField, equals: .username)
                        .onSubmit { focusedField = .password }
                        .keyboardType(.default)

                    SecureField("password", text: viewStore.binding(\.$password))
                        .focused($focusedField, equals: .password)
                }
                .multilineTextAlignment(.center)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .disableAutocorrection(true)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Done") { focusedField = nil }
                        }
                    }
                }

                HStack(spacing: 20.0) {
                    Button(
                        action: { viewStore.send(.login) },
                        label: { Text("Login") }
                    )
                    .buttonStyle(BigButtonStyle())
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .disabled(!viewStore.loginButtonEnabled)
                }
                .padding(20)

                Spacer()
            }
            .loadable(viewStore.binding(\.$isLoading))
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
                    reducer: CampusLogin.reducer,
                    environment: CampusLogin.Environment(
                        apiClient: .failing,
                        userDefaultsClient: .live()
                    )
                )
            )
        }
    }
}
