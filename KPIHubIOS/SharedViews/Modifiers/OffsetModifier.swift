//
//  OffsetModifier.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import SwiftUI

struct OffsetModifier: ViewModifier {
    var onChange: (CGFloat) -> Void

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: OffsetPreferenceKey.self,
                            value: proxy.frame(in: .global).minY
                        )
                    }
                }
            )
            .onPreferenceChange(OffsetPreferenceKey.self) { value in
                onChange(value)
            }
    }
}

struct OffsetPreferenceKey: PreferenceKey {

    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
