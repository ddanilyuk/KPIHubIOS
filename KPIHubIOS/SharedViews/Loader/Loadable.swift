//
//  Loadable.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI

struct Loadable: ViewModifier {
    @Binding var isVisible: Bool

    func body(content: Content) -> some View {
        content
            .disabled(isVisible)
            .overlay(isVisible ? Loader() : nil)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}

extension View {
    func loadable(_ isVisible: Binding<Bool>) -> some View {
        modifier(Loadable(isVisible: isVisible))
    }
}
