//
//  OffsetModifier.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import SwiftUI

public struct OffsetModifier: ViewModifier {
    public var onChange: (CGFloat) -> Void
    
    public init(onChange: @escaping (CGFloat) -> Void) {
        self.onChange = onChange
    }

    public func body(content: Content) -> some View {
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
