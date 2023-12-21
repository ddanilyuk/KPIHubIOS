//
//  GroupRozkladDayPicker.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import SwiftUI
import GeneralServices // TODO: ?

struct GroupRozkladDayPicker: View {
    var displayedDay: Lesson.Day
    var currentDay: Lesson.Day?
    var selectDay: (Lesson.Day?) -> Void

    var body: some View {
        HStack {
            ForEach(Lesson.Day.allCases, id: \.self) { element in
                Button(
                    action: { selectDay(element) },
                    label: {
                        Text("\(element.shortDescription)")
                            .font(.system(.body).bold())
                            .if(currentDay == element) { view in
                                ZStack(alignment: .topTrailing) {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 10)

                                    view
                                }
                            }
                    }
                )
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(element == displayedDay ? .primary : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
    }
}
