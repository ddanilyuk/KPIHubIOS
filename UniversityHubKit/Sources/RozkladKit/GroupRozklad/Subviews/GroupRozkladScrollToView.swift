//
//  GroupRozkladScrollToView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.06.2022.
//

import SwiftUI
import GeneralServices // TODO: ?

struct GroupRozkladScrollToView: View {
    enum Mode {
        case current
        case next

        init(currentLesson: CurrentLesson?) {
            switch currentLesson {
            case .some:
                self = .current

            case .none:
                self = .next
            }
        }

        var description: String {
            switch self {
            case .current:
                return "Зараз"

            case .next:
                return "Далі"
            }
        }

        var color: Color {
            switch self {
            case .current:
                return Color.orange

            case .next:
                return Color.blue
            }
        }
    }

    let mode: Mode

    var body: some View {
        Text(mode.description)
            .font(.system(.callout).bold())
            .frame(minWidth: 60)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(mode.color)
                    .shadow(
                        color: mode.color.opacity(0.2),
                        radius: 4,
                        x: 0,
                        y: 0
                    )
            )
    }
}
