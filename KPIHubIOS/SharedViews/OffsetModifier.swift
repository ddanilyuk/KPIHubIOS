//
//  OffsetModifier.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import SwiftUI

struct OffsetModifier: ViewModifier {

//    @State var offset: CGFloat = .zero

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
//            .overlay(
//                Color.red.opacity(0.2)
//                    .overlay(Text("\(offset)"))
//            )
//            .overlay {
//                Color.red.opacity(0.2)
//            }
    }

}

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


struct OffsetPreferenceKey: PreferenceKey {

    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct RectPreferenceKey: PreferenceKey {

    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
