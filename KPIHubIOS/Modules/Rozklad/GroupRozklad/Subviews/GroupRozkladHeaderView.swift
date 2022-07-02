//
//  GroupRozkladHeaderView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 16.06.2022.
//

import SwiftUI

// TODO: Replace with actions
struct GroupRozkladHeaderView: View {

    @ObservedObject var animation: GroupRozkladAnimationViewModel
    let groupName: String

    @Binding var selectedWeek: Lesson.Week?
    @Binding var selectedDay: Lesson.Day?

    @Binding var displayedWeek: Lesson.Week
    @Binding var displayedDay: Lesson.Day

    @Binding var headerBackgroundOpacity: CGFloat

    var currentWeek: Lesson.Week
    var currentDay: Lesson.Day?

    @Environment(\.safeAreaInsets) var safeAreaInsets

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                GroupRozkladTitleView(
                    title: groupName
                )

                GroupRozkladWeekPicker(
                    selectedWeek: $selectedWeek,
                    displayedWeek: $displayedWeek,
                    currentWeek: currentWeek
                )
            }

            GroupRozkladDayPicker(
                selectedDay: $selectedDay,
                displayedDay: $displayedDay,
                currentDay: currentDay
            )
            .padding(.bottom, 4)
        }
        .padding(.top, safeAreaInsets.top)
        .onChange(of: animation.position) { newValue in
            DispatchQueue.main.async {
                displayedDay = newValue.day
                displayedWeek = newValue.week
            }
        }
        .background(
            ZStack {
                Color.clear
                    .background(.regularMaterial, in: Rectangle())
                    .opacity(headerBackgroundOpacity)
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom) {
                        Image("shadow")
                            .resizable()
                            .opacity(headerBackgroundOpacity)
                            .frame(height: 4)
                    }
            }
        )
    }

}
