//
//  GroupRozkladHeaderView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 16.06.2022.
//

//import SwiftUI
//import ComposableArchitecture
//import GeneralServices // TODO: 

//struct GroupRozkladHeaderView: View {
//    struct ViewState: Equatable {
//        var position: GroupRozklad.State.Section.Position
//        let groupName: String
//        var currentDay: Lesson.Day?
//        var currentWeek: Lesson.Week = .first
//        
//        init(_ groupRozklad: GroupRozklad.State) {
//            self.position = groupRozklad.position
//            self.groupName = groupRozklad.groupName
//            self.currentWeek = groupRozklad.currentWeek
//            self.currentDay = groupRozklad.currentDay
//        }
//    }
//    
//    @ObservedObject var viewStore: ViewStore<ViewState, GroupRozklad.Action>    
//    @Binding var displayedWeek: Lesson.Week
//    @Binding var displayedDay: Lesson.Day
//    @Binding var headerBackgroundOpacity: CGFloat
//
//    var selectWeek: (Lesson.Week) -> Void
//    var selectDay: (Lesson.Day?) -> Void
//
//    @Environment(\.safeAreaInsets) var safeAreaInsets
//
//    @ViewBuilder
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
//                GroupRozkladTitleView(
//                    title: viewStore.groupName
//                )
//
//                GroupRozkladWeekPicker(
//                    displayedWeek: viewStore.position.week,
//                    currentWeek: viewStore.currentWeek,
//                    selectWeek: selectWeek
//                )
//            }
//
//            GroupRozkladDayPicker(
//                displayedDay: viewStore.position.day,
//                currentDay: viewStore.currentDay,
//                selectDay: selectDay
//            )
//            .padding(.bottom, 4)
//        }
//        .padding(.top, safeAreaInsets.top)
//        .background(
//            ZStack {
//                Color.clear
//                    .background(.regularMaterial, in: Rectangle())
//                    .opacity(headerBackgroundOpacity)
//                    .padding(.bottom, 4)
//                    .overlay(alignment: .bottom) {
//                        Image("shadow")
//                            .resizable()
//                            .opacity(headerBackgroundOpacity)
//                            .frame(height: 4)
//                    }
//            }
//        )
//    }
//}
