//
//  Shape+Ext.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import SwiftUI

extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}
