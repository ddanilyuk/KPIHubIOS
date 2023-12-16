//
//  LessonDetailsSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI

public struct LessonDetailsSectionView<Content: View>: View {
    let title: String
    var shadowColor = Color.black.opacity(0.05)
    var shadowRadius: CGFloat = 4
    var isEditing = false
    @ViewBuilder var content: Content
    @Environment(\.colorScheme) var colorScheme
    
    public init(
        title: String,
        shadowColor: SwiftUI.Color = Color.black.opacity(0.05),
        shadowRadius: CGFloat = 4,
        isEditing: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.isEditing = isEditing
        self.content = content()
    }

    public var body: some View {
        HStack {
            if isEditing {
                EditingView()
            }
            VStack(alignment: .leading, spacing: 4) {
                SectionHeader(title: title)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
                        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowRadius / 2)

                    content
                }
            }
        }
    }
}

private struct SectionHeader: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.system(.subheadline).weight(.regular))
            .padding(.horizontal, 16)
            .frame(height: 25)
    }
}
