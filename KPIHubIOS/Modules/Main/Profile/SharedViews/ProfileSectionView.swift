//
//  ProfileSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI

struct ProfileSectionView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    let content: Content

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
                .if(colorScheme == .light) { view in
                    view
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.system(.body).bold())

                content
            }
            .padding()
        }
    }
}
