//
//  GroupLessonsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct GroupLessonsView: View {

    let store: Store<GroupLessons.State, GroupLessons.Action>

    init(store: Store<GroupLessons.State, GroupLessons.Action>) {
        self.store = store
    }

    @State var selectedWeek: Lesson.Week?
    @State var selectedDay: Lesson.Day?

    @State var displayedWeek: Lesson.Week = .first
    @State var displayedDay: Lesson.Day = .monday

    @State var offsets: [CGFloat?] = Array(repeating: nil, count: 6 * 2)

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    TitleView(title: "ІВ-82")

                    WeekPicker(
                        selectedWeek: $selectedWeek,
                        displayedWeek: $displayedWeek
                    )

                    DayPicker(
                        selectedDay: $selectedDay,
                        displayedDay: $displayedDay
                    )
                }

                GeometryReader { geometryProxy in
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(viewStore.scheduleDays, id: \.id) { scheduleDay in
                                    Section(
                                        content: {
                                            if scheduleDay.lessons.isEmpty {
                                                emptyCell
                                            } else {
                                                ForEachStore(
                                                    self.store.scope(
                                                        state: { $0.lessonCells[scheduleDay.index] },
                                                        action: GroupLessons.Action.lessonCells(id:action:)
                                                    ),
                                                    content: {
                                                        LessonCellView(store: $0)
                                                            .padding()
                                                            .background(Color(.systemGroupedBackground))
                                                    }
                                                )
                                            }
                                        },
                                        header: {
                                            sectionHeader(scheduleDay: scheduleDay)
                                                .modifier(OffsetModifier())
                                                .onPreferenceChange(OffsetPreferenceKey.self) { value in
                                                    offsets[scheduleDay.index] = value
                                                }
                                                .onDisappear {
                                                    offsets[scheduleDay.index] = nil
                                                }
                                        }
                                    )
                                }

                                Rectangle()
                                    .fill(Color(.systemGroupedBackground))
                                    .frame(minHeight: geometryProxy.frame(in: .local).height - 44)
                            }
                            .onChange(of: selectedDay) { newValue in
                                guard let newSelectedDay = newValue else {
                                    return
                                }
                                withAnimation {
                                    // If scrolling from bottom to top is lagging
                                    proxy.scrollTo(
                                        ScheduleDay.id(week: displayedWeek, day: newSelectedDay),
                                        anchor: .top
                                    )
                                }
                                selectedDay = nil
                            }
                            .onChange(of: selectedWeek) { newValue in
                                guard let newSelectedWeek = newValue else {
                                    return
                                }
                                withAnimation {
                                    proxy.scrollTo(
                                        ScheduleDay.id(week: newSelectedWeek, day: displayedDay),
                                        anchor: .top
                                    )
                                }
                                selectedWeek = nil
                            }
                        }
                    }
                    .onChange(of: offsets) { newValue in
                        print("")
                        print(newValue.map { "\(Int(($0 ?? 0).rounded()))" }.joined(separator: " | "))
                        let value: Int = {
                            if let firstIndex = newValue.firstIndex(where: { $0 ?? 0 > 169 + 3 }) {
                                let result = max(firstIndex - 1, 0)
                                print(result)
                                return result

                            } else {
                                let result = newValue.count - 1
                                print(result)
                                return result
                            }
                        }()
                        switch value {
                        case (0..<6):
                            displayedWeek = .first
                            displayedDay = .init(rawValue: value + 1) ?? .monday

                        case (6...):
                            displayedWeek = .second
                            displayedDay = .init(rawValue: value - 5) ?? .monday

                        default:
                            return
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                    .coordinateSpace(name: "SCROLL")
                }
            }
            .navigationBarHidden(true)
        }
    }

    func sectionHeader(scheduleDay: ScheduleDay) -> some View {
        Text("\(scheduleDay.day.fullDescription). \(scheduleDay.week.description)")
            .font(.system(.headline))
            .foregroundColor(.black)
            .padding(.horizontal)
            .padding(.top)
            .frame(height: 44, alignment: .leading)
            .textCase(nil)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    var emptyCell: some View {
        Rectangle()
            .frame(height: 0.0)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

}

struct OffsetModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    Color.clear.opacity(0.2).preference(
                        key: OffsetPreferenceKey.self,
                        value: proxy.frame(in: .global).minY
                    )
                }
            )
    }

}

struct OffsetPreferenceKey: PreferenceKey {

    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct TitleView: View {

    let title: String

    var body: some View {
        Text("\(title)")
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(.title2).bold())
            .frame(height: 42)
    }
}

struct WeekPicker: View {

    @Binding var selectedWeek: Lesson.Week?
    @Binding var displayedWeek: Lesson.Week

    var body: some View {
        HStack {
            Button(
                action: { selectedWeek = .first },
                label: {
                    Text("1 тиждень")
                        .font(.system(.body).bold())
                }
            )
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(displayedWeek == .first ? .black : .secondary)

            Button(
                action: { selectedWeek = .second },
                label: {
                    Text("2 тиждень")
                        .font(.system(.body).bold())
                }
            )
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(displayedWeek == .second ? .black : .secondary)
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
    }
}

struct DayPicker: View {

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

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
