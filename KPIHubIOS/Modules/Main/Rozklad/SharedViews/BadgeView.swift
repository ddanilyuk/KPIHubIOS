//
//  BadgeView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI

struct BadgeView: View {
    let mode: LessonMode

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 4, height: 4)

            Text(mode.description)
        }
        .font(.system(.footnote).bold())
        .padding(.vertical, 0)
        .padding(.horizontal, 6)
        .foregroundColor(.white)
        .background(
            Rectangle()
                .fill(mode.backgroundColor)
                .cornerRadius(8, corners: [.topRight, .bottomLeft])
        )
    }
}

private extension LessonMode {
    var backgroundColor: Color {
        switch self {
        case .current:
            return .orange

        case .next:
            return .blue

        case .default:
            return .clear
        }
    }
}
