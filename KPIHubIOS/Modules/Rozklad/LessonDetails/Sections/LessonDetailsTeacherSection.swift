//
//  LessonDetailsTeacherSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct LessonDetailsTeacherSection: View {

    @Environment(\.colorScheme) var colorScheme

    var teachers: [String]
    var isEditing: Bool

    var body: some View {
        LessonDetailsSectionView(
            title: "Викладач",
            isEditing: isEditing,
            content: { content }
        )
    }

    var content: some View {
        VStack(spacing: 16) {
            ForEach(teachers, id: \.self) { teacher in
                VStack(spacing: 16) {
                    HStack(spacing: 0) {
                        LargeTagView(
                            icon: Image(systemName: "person"),
                            text: teacher,
                            color: .indigo
                        )
                        Spacer()
                    }
                    // If you add a separator, then text wrapping and layout will break
                    // if teacher != teachers.last {
                    //    Divider()
                    // }
                }
            }
        }
        .padding(16)
    }

}
