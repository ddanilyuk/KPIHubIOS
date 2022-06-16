//
//  GroupRozkladDayPicker.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import SwiftUI

struct GroupRozkladDayPicker: View {

    @Binding var selectedDay: Lesson.Day?
    @Binding var displayedDay: Lesson.Day

    var body: some View {
        HStack {
            ForEach(Lesson.Day.allCases, id: \.self) { element in
                Button(
                    action: { selectedDay = element },
                    label: {
                        Text("\(element.shortDescription)")
                            .font(.system(.body).bold())
                    }
                )
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(element == displayedDay ? .black : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
    }
    
}
