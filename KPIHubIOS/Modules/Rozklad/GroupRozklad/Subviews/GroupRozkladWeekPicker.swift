//
//  GroupRozkladWeekPicker.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import SwiftUI

struct GroupRozkladWeekPicker: View {

    @Binding var selectedWeek: Lesson.Week?
    @Binding var displayedWeek: Lesson.Week

    var body: some View {
        HStack {
            ForEach(Lesson.Week.allCases, id: \.self) { element in
                Button(
                    action: { selectedWeek = element },
                    label: {
                        Text("\(element.description)")
                            .font(.system(.body).bold())
                    }
                )
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(element == displayedWeek ? .black : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
    }

}
