//
//  LessonMode.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import CoreGraphics

enum LessonMode: Equatable {
    case current(CGFloat)
    case next
    case `default`

    var isCurrent: Bool {
        switch self {
        case .current:
            return true
        case .next,
                .default:
            return false
        }
    }

    var percent: CGFloat {
        switch self {
        case let .current(value):
            return value
        case .default:
            return 0
        case .next:
            return 0
        }
    }

    var description: String {
        switch self {
        case .current:
            return "Зараз"

        case .next:
            return "Далі"

        case .default:
            return ""
        }
    }
}
