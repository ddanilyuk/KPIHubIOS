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
        UITableView.appearance().sectionHeaderTopPadding = 0.0
        UITableView.appearance().sectionFooterHeight = 0.0

        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.001))
        UITableView.appearance().tableFooterView = view
        UITableView.appearance().estimatedSectionFooterHeight = 0.001
        UITableView.appearance().separatorStyle = .none
    }

    @State var selectedWeek: Lesson.Week = .first
    @State var selectedDay: Lesson.Day = .monday

    @State var displayedWeek: Lesson.Week = .first
    @State var displayedDay: Lesson.Day = .monday

    @State var test: [CGFloat?] = Array(repeating: nil, count: 6 * 2)

    struct OffsetsTest: Equatable {
        struct Offset: Equatable {
            let scheduleDay: Schedule.ScheduleDay
            var offset: CGFloat
        }

        var lower: Offset?
        var current: Offset?
        var higher: Offset?

        var description: String {
            return "\(lower?.scheduleDay.id ?? "no lower") \(lower?.offset ?? 0)"
        }
    }

    @State var offsetTest = OffsetsTest()

    @State var offsets: [Schedule.ScheduleDay: CGFloat] = [:]

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
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(viewStore.schedule.firstWeek, id: \.id) { scheduleDay in
                                    Section(
                                        content: {
                                            if scheduleDay.lessons.isEmpty {
                                                emptyCell
                                            } else {
                                                ForEach(scheduleDay.lessons, id: \.id) { _ in
                                                    LessonCellView(
                                                        store: Store(
                                                            initialState: LessonCell.State(),
                                                            reducer: LessonCell.reducer,
                                                            environment: LessonCell.Environment()
                                                        )
                                                    )
                                                    .padding()
                                                    .listRowInsets(EdgeInsets())
                                                    .background(Color(.systemGroupedBackground))
                                                    .listRowSeparator(.hidden)
                                                }
                                            }
                                        },
                                        header: {
                                            sectionHeader(scheduleDay: scheduleDay)
                                                .modifier(OffsetModifier())
                                                .onPreferenceChange(OffsetPreferenceKey.self) { value in
    //                                                if let nextValue = test[safe: scheduleDay.index + 1],
    //                                                   let nextValue = nextValue,
    //                                                 value > nextValue {
    //                                                    test[scheduleDay.index] = nil
    //                                                    return
    //                                                }
                                                    test[scheduleDay.index] = value
                                                    offsets[scheduleDay] = value
                                                }
                                                .onAppear {
                                                    print("onAppear \(scheduleDay.index)")
                                                }
                                                .onDisappear {
                                                    test[scheduleDay.index] = nil
                                                    print("onDisappear \(scheduleDay.index)")
                                                }

                                        },
                                        footer: { sectionFooter }
                                    )

    //                                .onDisappear {
    //                                    print("DISAPPEAR \(scheduleDay.id)")
    //                                    test[scheduleDay.index] = nil
    //                                }
                                    .listRowInsets(EdgeInsets())
                                }
                                .listRowInsets(EdgeInsets())

                                ForEach(viewStore.schedule.secondWeek, id: \.id) { scheduleDay in
                                    Section(
                                        content: {
                                            if scheduleDay.lessons.isEmpty {
                                                emptyCell
                                            } else {
                                                ForEach(scheduleDay.lessons, id: \.id) { _ in
                                                    LessonCellView(
                                                        store: Store(
                                                            initialState: LessonCell.State(),
                                                            reducer: LessonCell.reducer,
                                                            environment: LessonCell.Environment()
                                                        )
                                                    )
                                                    .padding()
                                                    .listRowInsets(EdgeInsets())
                                                    .background(Color(.systemGroupedBackground))
                                                    .listRowSeparator(.hidden)
                                                }
                                            }
                                        },
                                        header: {
                                            sectionHeader(scheduleDay: scheduleDay)
                                                .modifier(OffsetModifier())
                                                .onPreferenceChange(OffsetPreferenceKey.self) { value in
    //                                                if let nextValue = test[safe: scheduleDay.index + 1],
    //                                                   let nextValue = nextValue,
    //                                                   value > nextValue {
    //                                                    test[scheduleDay.index] = nil
    //                                                    return
    //                                                }
                                                    test[scheduleDay.index] = value
                                                    offsets[scheduleDay] = value
                                                }

                                        },
                                        footer: { sectionFooter }
                                    )
    //                                .onDisappear {
    //                                    print("DISAPPEAR \(scheduleDay.id)")
    //                                    test[scheduleDay.index] = nil
    //                                }
                                    .listRowInsets(EdgeInsets())
                                }

                                .listRowInsets(EdgeInsets())

                                Rectangle()
                                    .fill(Color(.systemGroupedBackground))
                                    .frame(minHeight: geometryProxy.frame(in: .local).height - 44)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                            }
                            .environment(\.defaultMinListRowHeight, 0.0)
                            .listStyle(.grouped)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .onChange(
                                of: selectedDay,
                                perform: { newValue in
                                    withAnimation {
                                        proxy.scrollTo(
                                            Schedule.ScheduleDay.id(week: displayedWeek, day: newValue),
                                            anchor: .top
                                        )
                                    }
                                }
                            )
                            .onChange(of: selectedWeek) { newValue in
                                withAnimation {
                                    proxy.scrollTo(
                                        Schedule.ScheduleDay.id(week: newValue, day: displayedDay),
                                        anchor: .top
                                    )
                                }
                            }
                        }
                    }
                    .overlay(Text("\(geometryProxy.frame(in: .local).height)"))
                    .onChange(of: offsets, perform: { newOffsets in
                        return
                        let list = newOffsets.sorted(by: { $0.1 > $1.1 })
//                        print("----")
//                        list.forEach { element in
//                            print(element.value)
//                        }
//                        print("----")

                        let list2 = newOffsets.sorted(by: { $0.1 < $1.1 })
//                        print("")
//                        print(list2.map { "\($0.key.id) \($0.value)" }.joined(separator: "\n"))
//                        print("")
//                        if let index = list2.firstIndex(where: { $0.1 > 169 }) {
//                            print(index)
//                        }


//                        print(list.forR)
                        //                let some = list.firstIndex(where: { $0.1 >= 192 })
                        if let scheduleDay = list.first(where: { $0.1 <= 169 + 4 }) {
                            displayedWeek = scheduleDay.key.week
                            displayedDay = scheduleDay.key.day
                        }

                        /// []
                        ///
                        ///
                        ///
//                        offsets.removeAll()
                    })
                    .onChange(of: test, perform: { newValue in
                        print("")
                        print("\(UIScreen.main.bounds.height)")
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

//                            selectedWeek = .first
//                            selectedDay = .init(rawValue: value + 1) ?? .monday

                        case (6...):
                            displayedWeek = .second
                            displayedDay = .init(rawValue: value - 5) ?? .monday

//                            selectedWeek = .second
//                            selectedDay = .init(rawValue: value - 5) ?? .monday

                        default:
                            return
                        }


                    })
                    .onChange(of: offsetTest, perform: { newValue in
//                        print(newValue.description)
                    })
                    .background(Color(.systemGroupedBackground))
                    .coordinateSpace(name: "SCROLL")
                }
            }
            .navigationBarHidden(true)
        }
    }

    let target = 169.0

    func sectionHeader(scheduleDay: Schedule.ScheduleDay) -> some View {
        Text("\(scheduleDay.day.fullDescription). \(scheduleDay.week.description)")
            .font(.system(.headline))
            .foregroundColor(.black)
            .padding(.horizontal)
            .padding(.top)
            .frame(height: 44, alignment: .leading)
            .textCase(nil)

            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .background(Color.red.opacity(0.3))
    }

    var sectionFooter: some View {
        EmptyView()
            .frame(height: 0.00001)
            .background(Color.green.opacity(0.9))
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    var emptyCell: some View {
        Rectangle()
            .frame(height: 0.00001)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

}

struct OffsetModifier: ViewModifier {

    @State var offset: CGFloat = .zero

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
            .onPreferenceChange(OffsetPreferenceKey.self) { value in
                offset = value
            }
            .overlay(
                Text("\(offset)")
            )

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
        "\(week.rawValue)\(day.rawValue)\(position.rawValue)"
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

    @Binding var selectedWeek: Lesson.Week
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

    @Binding var selectedDay: Lesson.Day
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
