//
//  RectModifier.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.07.2022.
//

import SwiftUI

struct RectModifier: ViewModifier {
    private let onChange: (CGRect) -> Void
    private let coordinateSpace: CoordinateSpaceProtocol
    
    init(
        coordinateSpace: some CoordinateSpaceProtocol,
        onChange: @escaping (CGRect) -> Void
    ) {
        self.onChange = onChange
        self.coordinateSpace = coordinateSpace
    }

    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: RectPreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace)
                )
            })
            .onPreferenceChange(RectPreferenceKey.self) { position in
                print("!! position: \(position)")
            }
//            .onPreferenceChange(RectPreferenceKey.self) { value in
//                print("!! value: \(value)")
//                onChange(value)
//            }
    }
}

private struct RectPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        
    }
}
