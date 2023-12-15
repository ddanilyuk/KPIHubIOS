//
//  Loadable.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI

public struct Loadable: ViewModifier {
    @Binding var isVisible: Bool

    public func body(content: Content) -> some View {
        content
            .disabled(isVisible)
            .overlay(isVisible ? Loader() : nil)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}

extension View {
    public func loadable(_ isVisible: Binding<Bool>) -> some View {
        modifier(Loadable(isVisible: isVisible))
    }
}
