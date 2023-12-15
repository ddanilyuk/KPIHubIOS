//
//  View+sync.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 01.07.2022.
//

import SwiftUI

extension View {
    public func synchronize<Value>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { _, newValue in
                second.wrappedValue = newValue
            }
            .onChange(of: second.wrappedValue) { _, newValue in
                first.wrappedValue = newValue
            }
    }
}
