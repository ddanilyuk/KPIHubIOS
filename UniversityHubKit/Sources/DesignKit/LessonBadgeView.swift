//
//  LessonBadgeView.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import SwiftUI

public struct LessonBadgeView: View {
    @Environment(\.designKit) private var designKit
    public let mode: Mode
    
    public init(mode: Mode) {
        self.mode = mode
    }

    public var body: some View {
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
                .fill(backgroundColor)
                .cornerRadius(8, corners: [.topRight, .bottomLeft])
        )
    }
    
    var backgroundColor: Color {
        switch mode {
        case .current:
            return designKit.currentLessonColor
            
        case .next:
            return designKit.nextLessonColor
        }
    }
}

extension LessonBadgeView {
    public enum Mode {
        case current
        case next
        
        var description: String {
            switch self {
            case .current:
                return "Зараз"
                
            case .next:
                return "Далі"
            }
        }
    }
}
