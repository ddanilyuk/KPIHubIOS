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

    @State var savedOffsets: [CGFloat?] = Array(repeating: nil, count: 6 * 2)
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
                                ForEach(viewStore.sectionStates, id: \.id) { section in
                                    VStack(spacing: 0) {
                                        Section(
                                            content: {
                                                ForEachStore(
                                                    self.store.scope(
                                                        state: \.sectionStates[section.index].lessonCells,
                                                        action: GroupLessons.Action.lessonCells(id:action:)
                                                    ),
                                                    content: LessonCellView.init(store:)
                                                )
                                            },
                                            header: {
                                                sectionHeader(
                                                    day: section.day,
                                                    week: section.week
                                                )
                                            }
                                        )
                                        .id(section.id)
                                    }
                                    .modifier(OffsetModifier())
                                    .onPreferenceChange(OffsetPreferenceKey.self) { value in
                                        offsets[section.index] = value
                                    }
                                    .onDisappear {
                                        offsets[section.index] = nil
                                    }
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
                                        GroupLessons.State.SectionState.id(week: displayedWeek, day: newSelectedDay),
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
                                        GroupLessons.State.SectionState.id(week: newSelectedWeek, day: displayedDay),
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
                            if newValue.compactMap({ $0 }).count <= 1, let index = newValue.firstIndex(where: { $0 != nil }) {
                                print("index \(index)")
                                return index

                            } else if let firstIndex = newValue.firstIndex(where: { $0 ?? 0 > 170 }) {
                                let result = max(firstIndex - 1, 0)
                                print("firstIndex \(result)")
                                return result

                            } else if let lastIndex = newValue.lastIndex(where: { $0 ?? CGFloat.infinity < 168 }) {
                                let result = min(lastIndex + 1, 11)
                                print("lastIndex \(result)")
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
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                offsets = savedOffsets
            }
            .onDisappear {
                savedOffsets = offsets
            }
        }
    }

    func sectionHeader(day: Lesson.Day, week: Lesson.Week) -> some View {
        HStack {
            Text("\(day.fullDescription). \(week.description)")
                .font(.system(.headline))
                .foregroundColor(.black)
                .padding(.horizontal)
                .padding(.top)
                .textCase(nil)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            Spacer()
        }
        .frame(height: 44)
    }

}

struct OffsetModifier: ViewModifier {

    @State var offset: CGFloat = .zero

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    GeometryReader { proxy in
                        Color.clear.opacity(0.2).preference(
                            key: OffsetPreferenceKey.self,
                            value: proxy.frame(in: .global).minY
                        )
                    }
                }
            )
            .onPreferenceChange(OffsetPreferenceKey.self) { value in
                offset = value
            }
//            .overlay(
//                Color.red.opacity(0.2)
//                    .overlay(Text("\(offset)"))
//            )


//            .overlay {
//                Color.red.opacity(0.2)
//            }
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
