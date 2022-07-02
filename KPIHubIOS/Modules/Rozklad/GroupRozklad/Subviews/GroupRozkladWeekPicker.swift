//
//  GroupRozkladWeekPicker.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import SwiftUI

// TODO: Change actions
struct GroupRozkladWeekPicker: View {

    @Binding var selectedWeek: Lesson.Week?
    @Binding var displayedWeek: Lesson.Week
    var currentWeek: Lesson.Week

    var body: some View {
        HStack {
            ForEach(Lesson.Week.allCases, id: \.self) { element in
                Button(
                    action: { selectedWeek = element },
                    label: {
                        Text("\(element.description)")
                            .font(.system(.body).bold())
                            .if(currentWeek == element) { view in
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
                .foregroundColor(element == displayedWeek ? .black : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
    }

}
