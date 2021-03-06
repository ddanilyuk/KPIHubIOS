//
//  View+sync.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 01.07.2022.
//

import SwiftUI

extension View {

    func synchronize<Value>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
    
}
