//
//  RozkladView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import SwiftUI
import DesignKit
import ComposableArchitecture
import RozkladFeature

@ViewAction(for: RozkladFeature.self)
struct RozkladView: View {
    @Bindable var store: StoreOf<RozkladFeature>
    @Environment(\.designKit) private var designKit
        
    var body: some View {
        _ = Self._printChanges()
        return VStack {
            // TODO: For some reason this view cause re-render
            RozkladHeaderView(
                store: store.scope(state: \.header, action: \.view.header)
            )
            ScrollView {
                LazyVStack {
                    ForEach(
                        store.scope(state: \.rows, action: \.view.rows),
                        id: \.state.id
                    ) { childStore in
                        RozkladRowProviderView(store: childStore) { cellStore in
                            RozkladLessonView(store: cellStore)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .modifier(
                IDHolder(id: $store.selectedID.sending(\.view.currentIDChanged))
                )
//            .scrollPosition(id: $id, anchor: .top)
            .background(designKit.backgroundColor)
        }
        .navigationTitle("Розклад")
    }
}

private struct IDHolder: ViewModifier {
    @Binding var id: String?
    
//    var onChange: (String?) -> Void
    
    func body(content: Content) -> some View {
        content
            .scrollPosition(id: $id, anchor: .top)
            .onChange(of: id) { _, newValue in
                print("!! ID change: \(newValue)")
            }
    }
}


struct RozkladHeaderView: View {
    let store: StoreOf<RozkladHeaderFeature>
    
    init(store: StoreOf<RozkladHeaderFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            HStack {
                RozkladWeekPicker(
                    displayedWeek: RozkladWeekPicker.Week(rawValue: store.currentLessonDay.week) ?? .first,
                    currentWeek: .second,
                    selectWeek: {
                        store.send(.view(.selectWeekButtonTapped($0.rawValue)))
                    }
                )
            }
            
            RozkladDayPicker(
                displayedDay: RozkladDayPicker.Day(rawValue: store.currentLessonDay.day) ?? .monday,
                currentDay: .thursday,
                selectDay: {
                    store.send(.view(.selectDayButtonTapped($0.rawValue)))
                }
            )
        }

    }
}

struct RozkladWeekPicker: View {
    let displayedWeek: Week
    let currentWeek: Week
    let selectWeek: (Week) -> Void
    
    enum Week: Int, CaseIterable {
        case first = 1
        case second
        
        var description: String {
            switch self {
            case .first:
                return "1 тиждень"
            case .second:
                return "2 тиждень"
            }
        }
    }

    var body: some View {
        HStack {
            ForEach(Week.allCases, id: \.self) { week in
                Button(
                    action: { selectWeek(week) },
                    label: {
                        weekViewButtonLabel(for: week)
                    }
                )
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(week == displayedWeek ? .primary : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
    }
    
    @ViewBuilder
    private func weekViewButtonLabel(for week: Week) -> some View {
        Text(week.description)
            .font(.system(.body).bold())
            .overlay(alignment: .topTrailing) {
                if currentWeek == week {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                        .offset(x: 10)
                } else {
                    EmptyView()
                }
            }
    }
}


struct RozkladDayPicker: View {
    enum Day: Int, CaseIterable, Equatable {
        case monday = 1
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        
        var shortDescription: String {
            switch self {
            case .monday:
                return "ПН"
            case .tuesday:
                return "ВТ"
            case .wednesday:
                return "СР"
            case .thursday:
                return "ЧТ"
            case .friday:
                return "ПТ"
            case .saturday:
                return "СБ"
            }
        }
    }
    
    var displayedDay: Day
    var currentDay: Day?
    var selectDay: (Day) -> Void

    var body: some View {
        HStack {
            ForEach(Day.allCases, id: \.self) { day in
                Button(
                    action: { selectDay(day) },
                    label: { dayViewButtonLabel(for: day) }
                )
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(day == displayedDay ? .primary : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
    }
    
    @ViewBuilder
    private func dayViewButtonLabel(for day: Day) -> some View {
        Text(day.shortDescription)
            .font(.system(.body).bold())
            .overlay(alignment: .topTrailing) {
                if currentDay == day {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                        .offset(x: 10)
                } else {
                    EmptyView()
                }
            }
    }
}
