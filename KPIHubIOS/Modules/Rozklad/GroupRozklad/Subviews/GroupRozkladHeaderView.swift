//
//  GroupRozkladHeaderView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 16.06.2022.
//

import SwiftUI

struct GroupRozkladHeaderView: View {

    @ObservedObject var animation: GroupRozkladAnimationViewModel
    let groupName: String

    @Binding var selectedWeek: Lesson.Week?
    @Binding var selectedDay: Lesson.Day?

    @Binding var displayedWeek: Lesson.Week
    @Binding var displayedDay: Lesson.Day

    var currentWeek: Int
    var currentDay: Int

    var body: some View {
        VStack(spacing: 0) {
            GroupRozkladTitleView(
                title: groupName
            )

            GroupRozkladWeekPicker(
                selectedWeek: $selectedWeek,
                displayedWeek: $displayedWeek,
                currentWeek: currentWeek
            )

            GroupRozkladDayPicker(
                selectedDay: $selectedDay,
                displayedDay: $displayedDay,
                currentDay: currentDay
            )
        }
        .onChange(of: animation.position) { newValue in
            DispatchQueue.main.async {
                displayedDay = newValue.day
                displayedWeek = newValue.week
            }
        }
    }

}
