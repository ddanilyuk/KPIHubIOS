//
//  GroupRozkladHeaderView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 16.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct GroupRozkladHeaderView: View {
    struct ViewState: Equatable {
        var position: RozkladPosition?
        let groupName: String
        var currentDay: Lesson.Day?
        var currentWeek: Lesson.Week = .first
        
        init(_ groupRozklad: GroupRozklad.State) {
            position = groupRozklad.position
            groupName = groupRozklad.groupName
            currentWeek = groupRozklad.currentWeek
            currentDay = groupRozklad.currentDay
        }
    }
    
    @ObservedObject private var viewStore: ViewStore<ViewState, GroupRozklad.Action.View>
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    private let backgroundOpacity: CGFloat
    
    init(store: StoreOf<GroupRozklad>, backgroundOpacity: CGFloat) {
        viewStore = ViewStore(store, observe: ViewState.init, send: { .view($0) })
        self.backgroundOpacity = backgroundOpacity
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                GroupRozkladTitleView(title: viewStore.groupName)

                GroupRozkladWeekPicker(
                    displayedWeek: viewStore.position?.week ?? .first,
                    currentWeek: viewStore.currentWeek
                ) { newWeek in
                    viewStore.send(.selectWeek(newWeek))
                }
            }

            GroupRozkladDayPicker(
                displayedDay: viewStore.position?.day ?? .monday,
                currentDay: viewStore.currentDay
            ) { newDay in
                viewStore.send(.selectDay(newDay))
            }
            .padding(.bottom, 4)
        }
        .padding(.top, safeAreaInsets.top)
        .background(
            ZStack {
                Color.clear
                    .background(.regularMaterial, in: Rectangle())
                    .opacity(backgroundOpacity)
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom) {
                        Image("shadow")
                            .resizable()
                            .opacity(backgroundOpacity)
                            .frame(height: 4)
                    }
            }
        )
    }
}
