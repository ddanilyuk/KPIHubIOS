//
//  GroupLessonsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct GroupLessonsView: View {

    @State var selectedWeek: Lesson.Week?
    @State var selectedDay: Lesson.Day?

    @State var displayedWeek: Lesson.Week = .first
    @State var displayedDay: Lesson.Day = .monday

    @State var savedOffsets: [CGFloat?] = Array(
        repeating: nil,
        count: GroupLessons.State.Section.Position.count
    )
    @State var offsets: [CGFloat?] = Array(
        repeating: nil,
        count: GroupLessons.State.Section.Position.count
    )

    let store: Store<GroupLessons.State, GroupLessons.Action>

    init(store: Store<GroupLessons.State, GroupLessons.Action>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    GroupTitleView(
                        title: viewStore.groupName
                    )

                    GroupLessonsWeekPicker(
                        selectedWeek: $selectedWeek,
                        displayedWeek: $displayedWeek
                    )

                    GroupLessonsDayPicker(
                        selectedDay: $selectedDay,
                        displayedDay: $displayedDay
                    )
                }

                GeometryReader { geometryProxy in
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(viewStore.sections, id: \.id) { section in
                                    VStack(spacing: 0) {
                                        Section(
                                            content: {
                                                ForEachStore(
                                                    self.store.scope(
                                                        state: \.sections[section.index].lessonCells,
                                                        action: GroupLessons.Action.lessonCells(id:action:)
                                                    ),
                                                    content: LessonCellView.init(store:)
                                                )
                                            },
                                            header: {
                                                sectionHeader(
                                                    day: section.position.day,
                                                    week: section.position.week
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

                                // TODO: Handle if in last section.count != 0
                                Rectangle()
                                    .background(Color.screenBackground)
                                    .frame(minHeight: geometryProxy.frame(in: .local).height - 44)
                            }
                            .onChange(of: selectedDay) { newValue in
                                guard let newSelectedDay = newValue else {
                                    return
                                }
                                withAnimation {
                                    // If scrolling from bottom to top is lagging
                                    proxy.scrollTo(
                                        GroupLessons.State.Section.id(
                                            week: displayedWeek,
                                            day: newSelectedDay
                                        ),
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
                                        GroupLessons.State.Section.id(
                                            week: newSelectedWeek,
                                            day: displayedDay
                                        ),
                                        anchor: .top
                                    )
                                }
                                selectedWeek = nil
                            }
                        }
                    }
                    .onChange(of: offsets) { newValue in
                        let topIndex = calculateTopIndex(offsets: newValue)
                        let sectionPosition = GroupLessons.State.Section.Position(index: topIndex)
                        displayedDay = sectionPosition.day
                        displayedWeek = sectionPosition.week
                    }
                    .background(Color.screenBackground)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewStore.send(.onAppear)
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

    func calculateTopIndex(offsets: [CGFloat?]) -> Int {
        let target: CGFloat = 169.0

        if offsets.compactMap({ $0 }).count <= 1, let index = offsets.firstIndex(where: { $0 != nil }) {
            return index

        } else if let firstIndex = offsets.firstIndex(where: { $0 ?? 0 > target + 1 }) {
            let result = max(firstIndex - 1, 0)
            return result

        } else if let lastIndex = offsets.lastIndex(where: { $0 ?? CGFloat.infinity < target - 1 }) {
            let result = min(lastIndex + 1, 11)
            return result

        } else {
            let result = offsets.count - 1
            return result
        }
    }

}
