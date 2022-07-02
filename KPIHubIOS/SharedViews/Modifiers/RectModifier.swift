//
//  RectModifier.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.07.2022.
//

import SwiftUI

struct RectModifier: ViewModifier {

    @State var value: CGRect = .zero
    var onChange: (CGRect) -> Void

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: RectPreferenceKey.self,
                            value: proxy.frame(in: .local)
                        )
                    }
                }
            )
            .onPreferenceChange(RectPreferenceKey.self) { value in
                onChange(value)
                self.value = value
            }
    }

}

struct RectPreferenceKey: PreferenceKey {

    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
    
}
