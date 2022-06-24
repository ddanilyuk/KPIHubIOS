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

    var currentWeek: Lesson.Week
    var currentDay: Lesson.Day?

    @Environment(\.safeAreaInsets) var safeAreaInsets

    @Binding var headerBackgroundOpacity: CGFloat

    @State var showShadow: Bool = false

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
//        .if(showBackground) { view in
//            view
//
//        }
        .background(
            ZStack {
//                Rectangle()
//                    .fill(Color.red.opacity(0.001))
//                    .padding(.bottom, 4)
//                    .shadow(
//                        color: .black.opacity(1),
//                        radius: 2,
//                        x: 0,
//                        y: 0
//                    )
//                    .animation(.easeOut(duration: 0.1), value: showShadow)
//                    .zIndex(1)

                Color.clear
                    .background(.regularMaterial, in: Rectangle())
                    .opacity(headerBackgroundOpacity)
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom, content: {
                        Image("shadow")
                            .resizable()
                            .opacity(headerBackgroundOpacity)
                            .frame(height: 4)
                    })
//                    .overlay(alignment: .bottom) (
//                        Image("shadow")
//                    )
            }

        )
        .onChange(of: headerBackgroundOpacity) { newValue in
            showShadow = newValue == 1
        }
//        .overlay(
//            Text("\(showBackground ? "true": "false")")
//        )

    }

}
