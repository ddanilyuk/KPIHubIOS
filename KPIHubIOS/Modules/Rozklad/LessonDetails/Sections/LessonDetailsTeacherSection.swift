//
//  LessonDetailsTeacherSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct LessonDetailsTeacherSection: View {

    var teachers: [Teacher]
    var isEditing: Bool
    var onTap: () -> Void

    var body: some View {
        LessonDetailsSectionView(
            title: "Викладач",
            isEditing: isEditing,
            onTap: onTap,
            content: { content }
        )
    }

    var content: some View {
        VStack(spacing: 16) {
            ForEach(teachers, id: \.self) { teacher in
                VStack(spacing: 16) {
                    HStack {
                        LargeTagView(
                            icon: Image(systemName: "person"),
                            text: teacher.shortName,
                            backgroundColor: Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255),
                            accentColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
                        )
                        Spacer()
                    }
                    if teacher != teachers.last {
                        Divider()
                    }
                }
            }
        }
    }

}
