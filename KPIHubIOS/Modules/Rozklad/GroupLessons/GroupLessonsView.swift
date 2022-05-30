//
//  GroupLessonsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct GroupLessonsView: View {

    @Environment(\.defaultMinListRowHeight) var minRowHeight


    let store: Store<GroupLessons.State, GroupLessons.Action>

    let schedule = Lesson.Schedule(lessons: Lesson.mocked)

    init(store: Store<GroupLessons.State, GroupLessons.Action>) {
        self.store = store
//        UITableView.appearance().sectionHeaderTopPadding = 0.0
    }

    @State var selectedDay: Lesson.Day = .monday

    @State var displayedDay: Lesson.Day = .monday

    @State var offsets: [Lesson.Day: CGFloat] = [:]

    var body: some View {
        VStack {
            VStack {
                Text("ІВ-82")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(.title2).bold())
                    .frame(height: 42)

                HStack {

                    Button(
                        action: {

                        },
                        label: {
                            Text("1 тиждень")
                                .font(.system(.body).bold())
                        }
                    )
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(.black)

                    Button(
                        action: {

                        },
                        label: {
                            Text("2 тиждень")
                                .font(.system(.body).bold())
                        }
                    )
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .frame(height: 40)

                HStack {
                    ForEach(Lesson.Day.allCases, id: \.self) { element in
                        Button(
                            action: {
                                self.selectedDay = element
//                                self.displayedDay = element
                            },
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

//            .opacity(0.1)

            ScrollViewReader { proxy in
                List {
                    ForEach(schedule.firstWeek, id: \.id) { scheduleDay in

                        Section(
                            content: {
                                if scheduleDay.lessons.isEmpty {
                                    Rectangle()
//                                        .fill(Color.red.opacity(0.3))
//                                        .frame(maxWidth: CGFloat.leastNonzeroMagnitude)
                                        .frame(height: 0.001)
//                                        .background(Color.green.opacity(0.3))
                                        .listRowInsets(EdgeInsets())

                                } else {
                                    ForEach(scheduleDay.lessons, id: \.id) { lesson in
                                        Text(lesson.names[0])
                                            .frame(height: 50)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.red.opacity(0.3))
                                            .listRowInsets(EdgeInsets())

                                    }
                                }

                            },
                            header: {
                                Text("\(scheduleDay.day.fullDescription). 1 тиждень")
                                    .font(.system(.headline))
                                    .foregroundColor(.black.opacity(0.1))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .textCase(nil)
                                    .background(Color.red.opacity(0.3))
                                    .modifier(OffsetModifier())
                                    .onPreferenceChange(OffsetPreferenceKey.self) { value in
                                        offsets[scheduleDay.day] = value
                                    }
                                    .listRowInsets(EdgeInsets())
//                                    .listRowInsets(EdgeInsets())


                            },
                            footer: {
                                EmptyView()
                                    .frame(height: 0)
                                    .listRowInsets(EdgeInsets())
//                                    .listRowInsets(EdgeInsets())
                            }
                        )

                    }
                }
//                .interspe
                .environment(\.defaultMinListRowHeight, 0.0)
//                .environment(\.defaultMinListHeaderHeight, 0.0)

//                .environment(minRowHeight, 0)
                .listStyle(.grouped)
                .listRowInsets(EdgeInsets())
                .onChange(
                    of: selectedDay,
                    perform: { newValue in
                        withAnimation {
                            proxy.scrollTo("test\(selectedDay.rawValue)", anchor: .top)
                        }
                    }
                )
            }
            .onChange(of: offsets, perform: { newOffsets in
                let list = newOffsets.sorted(by: { $0.1 > $1.1 })
//                let some = list.firstIndex(where: { $0.1 >= 192 })
                if let sceduleDay = list.first(where: { $0.1 <= 192 + 16 }) {
                    displayedDay = sceduleDay.key
                }
            })
            .background(Color(.systemGroupedBackground))
            .coordinateSpace(name: "SCROLL")
        }
        .navigationBarHidden(true)
    }

}

struct OffsetModifier: ViewModifier {

    @State var offset: CGFloat = .zero

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    Color.blue.opacity(0.2).preference(
                        key: OffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("SCROLL")).minY
                    )
                }
            )
//            .overlay(
//                Text("\(offset)")
//            )

    }

}

struct OffsetPreferenceKey: PreferenceKey {

    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension Lesson: Identifiable {

    var id: String {
        "\(position.rawValue)\(day.rawValue)\(week.rawValue)"
    }
}

extension Lesson {
    struct Schedule {

        var firstWeek: [ScheduleDay]
        var secondWeek: [ScheduleDay]

        struct ScheduleDay: Identifiable {
            let day: Lesson.Day
            var lessons: [Lesson]

            var id: String {
                "test\(day.rawValue)"
            }
        }

        init(lessons: [Lesson]) {
            self.firstWeek = Lesson.Day.allCases.map { ScheduleDay(day: $0, lessons: []) }
            self.secondWeek = Lesson.Day.allCases.map { ScheduleDay(day: $0, lessons: []) }

            for lesson in lessons {
                switch lesson.week {
                case .first:
                    self.firstWeek[lesson.day.rawValue - 1].lessons.append(lesson)
                case .second:
                    self.secondWeek[lesson.day.rawValue - 1].lessons.append(lesson)
                }
            }
        }
    }
}


extension Lesson {
    static let mocked: [Lesson] = [
        Lesson(
            names: ["First Monday"],
            teachers: [],
            locations: [],
            position: .first,
            day: .monday,
            week: .first
        ),
        Lesson(
            names: ["Second Monday"],
            teachers: [],
            locations: [],
            position: .second,
            day: .monday,
            week: .first
        ),
        Lesson(
            names: ["Third Monday"],
            teachers: [],
            locations: [],
            position: .third,
            day: .monday,
            week: .first
        ),
        Lesson(
            names: ["Fourth Monday"],
            teachers: [],
            locations: [],
            position: .fourth,
            day: .monday,
            week: .first
        ),

        Lesson(
            names: ["First Tue"],
            teachers: [],
            locations: [],
            position: .first,
            day: .tuesday,
            week: .first
        ),
        Lesson(
            names: ["Third Tue"],
            teachers: [],
            locations: [],
            position: .third,
            day: .tuesday,
            week: .first
        ),
        Lesson(
            names: ["Fourth Tue"],
            teachers: [],
            locations: [],
            position: .fourth,
            day: .tuesday,
            week: .first
        ),

        Lesson(
            names: ["Second Wed"],
            teachers: [],
            locations: [],
            position: .second,
            day: .wednesday,
            week: .first
        ),
        Lesson(
            names: ["Third Wed"],
            teachers: [],
            locations: [],
            position: .third,
            day: .wednesday,
            week: .first
        ),
        Lesson(
            names: ["Fourth Wed"],
            teachers: [],
            locations: [],
            position: .fourth,
            day: .wednesday,
            week: .first
        ),
    ]

}
