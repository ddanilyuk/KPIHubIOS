//
//  TeacherSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct TeacherSection: View {

    var teachers: [Teacher]
    var isEditing: Bool
    var onTap: () -> Void

    var body: some View {
        HStack {
            if isEditing {
                EditingView()
            }

            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(title: "Викладач")

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)

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
                    .padding(16)
                }
            }
        }
        .onTapGesture {
            onTap()
        }
    }

}
