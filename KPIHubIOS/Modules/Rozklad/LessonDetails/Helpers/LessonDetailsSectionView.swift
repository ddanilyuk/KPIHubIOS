//
//  LessonDetailsSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI

struct LessonDetailsSectionView<Content: View>: View {

    let title: String
    var shadowColor: Color = Color.black.opacity(0.05)
    var shadowRadius: CGFloat = 4
    var isEditing: Bool = false
    var onTap: (() -> Void)?
    @ViewBuilder var content: Content

    var body: some View {
        HStack {
            if isEditing {
                EditingView()
            }
            VStack(alignment: .leading, spacing: 4) {
                SectionHeader(title: title)

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowRadius / 2)

                    content
                }
            }
        }
        .onTapGesture {
            onTap?()
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
