//
//  LessonDetailsTypeSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import DesignKit

struct LessonDetailsTypeSection: View {
    var type: String

    var body: some View {
        LessonDetailsSectionView(
            title: "Тип",
            content: {
                HStack {
                    LargeTagView(
                        icon: Image(systemName: "graduationcap"),
                        text: type,
                        color: .cyan
                    )
                    Spacer()
                }
                .padding(16)
            }
        )
    }
}
