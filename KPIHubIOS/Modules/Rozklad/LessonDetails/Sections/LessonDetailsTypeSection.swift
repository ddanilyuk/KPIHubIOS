//
//  LessonDetailsTypeSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

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
                        backgroundColor: Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255),
                        accentColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
                    )
                    Spacer()
                }
                .padding(16)
            }
        )
    }

}
