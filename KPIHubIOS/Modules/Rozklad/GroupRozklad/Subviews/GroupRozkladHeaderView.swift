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

    @Binding var displayedWeek: Lesson.Week
    @Binding var displayedDay: Lesson.Day

    @Binding var headerBackgroundOpacity: CGFloat

    var selectWeek: (Lesson.Week) -> Void
    var selectDay: (Lesson.Day?) -> Void

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
                    displayedWeek: displayedWeek,
                    currentWeek: currentWeek,
                    selectWeek: selectWeek
                )
            }

            GroupRozkladDayPicker(
                displayedDay: displayedDay,
                currentDay: currentDay,
                selectDay: selectDay
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
