//
//  LessonDetailsTeacherSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct LessonDetailsTeacherSection: View {

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
                    HStack {
                        LargeTagView(
                            icon: Image(systemName: "person"),
                            text: teacher,
                            backgroundColor: Color.indigo.lighter(by: 0.9),
                            accentColor: Color.indigo
                        )
                        Spacer()
                    }
                    if teacher != teachers.last {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
    }

}
