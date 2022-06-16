//
//  GroupLessonsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

// We need to set in root of the file because we don't need to recreate it with GroupLessonsView
// and we don't need to body in GroupLessonsView when AnimationViewModel changes.
private var animationModel: AnimationViewModel = .init()

struct GroupLessonsView: View {

    @State var selectedWeek: Lesson.Week?
    @State var selectedDay: Lesson.Day?

    @State var displayedWeek: Lesson.Week = .first
    @State var displayedDay: Lesson.Day = .monday

    @State var lastSection: [CGFloat] = []

    let store: Store<GroupLessons.State, GroupLessons.Action>

    init(store: Store<GroupLessons.State, GroupLessons.Action>) {
        self.store = store

        UITableView.appearance().sectionHeaderTopPadding = 0
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                GroupLessonsHeaderView(
                    animation: animationModel,
                    groupName: viewStore.groupName,
                    selectedWeek: $selectedWeek,
                    selectedDay: $selectedDay,
                    displayedWeek: $displayedWeek,
                    displayedDay: $displayedDay
                )

                scrollView
            }
            .navigationBarHidden(true)
            .onAppear {
                viewStore.send(.onAppear)
                animationModel.restore()
            }
            .onDisappear {
                animationModel.save()
            }
        }
    }

    var scrollView: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geometryProxy in
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(viewStore.sections, id: \.id) { section in
                                sectionView(for: section)
                            }
                            Rectangle()
                                .fill(Color.screenBackground)
                                .frame(
                                    minHeight: max(
                                        0,
                                        geometryProxy.frame(in: .local).height - 44 - lastSection.reduce(0.0, +)
                                    )
                                )
                        }
                    }
                    .onChange(of: selectedDay) { changeSelectedDay($0, proxy: proxy) }
                    .onChange(of: selectedWeek) { changeSelectedWeek($0, proxy: proxy) }
                }
                .listStyle(.grouped)
                .background(Color.screenBackground)
            }
        }
    }

    func sectionView(for section: GroupLessons.State.Section) -> some View {
        Section(
            content: {
                ForEachStore(
                    self.store.scope(
                        state: \.sections[section.index].lessonCells,
                        action: GroupLessons.Action.lessonCells(id:action:)
                    ),
                    content: { store in
                        LessonCellView(store: store)
                            .if(section.index == 11) { view in
                                view.modifier(
                                    RectModifier {
                                        lastSectionOffsetModifiers(
                                            index: ViewStore(store).state.lesson.position.rawValue,
                                            height: $0.height
                                        )
                                    }
                                )
                            }
                    }
                )
            },
            header: {
                HStack {
                    let day = section.position.day.fullDescription
                    let week = section.position.week.description
                    Text("\(day). \(week)")
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
                .modifier(OffsetModifier { value in
                    DispatchQueue.main.async {
                        animationModel.setOffset(for: section.index, value: value)
                    }
                })
                .onDisappear {
                    DispatchQueue.main.async {
                        animationModel.setOffset(for: section.index, value: nil)
                    }
                }
            }
        )
        .id(section.id)
        .listRowInsets(EdgeInsets())
    }

    func lastSectionOffsetModifiers(index: Int, height: CGFloat) {
        if lastSection[safe: index] == nil {
            lastSection.append(height)
        } else {
            lastSection[index] = height
        }
    }

    func changeSelectedDay(_ newValue: Lesson.Day?, proxy: ScrollViewProxy) {
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

    func changeSelectedWeek(_ newValue: Lesson.Week?, proxy: ScrollViewProxy) {
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

struct GroupLessonsHeaderView: View {

    @ObservedObject var animation: AnimationViewModel
    let groupName: String

    @Binding var selectedWeek: Lesson.Week?
    @Binding var selectedDay: Lesson.Day?

    @Binding var displayedWeek: Lesson.Week
    @Binding var displayedDay: Lesson.Day

    var body: some View {
        VStack(spacing: 0) {
            GroupTitleView(
                title: groupName
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
        .onChange(of: animation.position) { newValue in
            DispatchQueue.main.async {
                displayedDay = newValue.day
                displayedWeek = newValue.week
            }
        }
    }

}
