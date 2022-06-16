//
//  GroupRozkladView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

// We need to set in root of the file because we don't need to recreate it with GroupRozkladView
// and we don't need to body in GroupRozkladView when GroupRozkladAnimationViewModel changes.
private var animationModel: GroupRozkladAnimationViewModel = .init()

struct GroupRozkladView: View {

    @State var selectedWeek: Lesson.Week?
    @State var selectedDay: Lesson.Day?

    @State var displayedWeek: Lesson.Week = .first
    @State var displayedDay: Lesson.Day = .monday

    @State var lastSection: [CGFloat] = []

    let store: Store<GroupRozklad.State, GroupRozklad.Action>

    init(store: Store<GroupRozklad.State, GroupRozklad.Action>) {
        self.store = store

        UITableView.appearance().sectionHeaderTopPadding = 0
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                GroupRozkladHeaderView(
                    animation: animationModel,
                    groupName: viewStore.groupName,
                    selectedWeek: $selectedWeek,
                    selectedDay: $selectedDay,
                    displayedWeek: $displayedWeek,
                    displayedDay: $displayedDay,
                    currentWeek: viewStore.currentWeek,
                    currentDay: viewStore.currentDay
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
                    .onChange(of: viewStore.scrollTo) { newValue in
                        print(newValue)
                        guard let scrollPosition = newValue else {
                            return
                        }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        withAnimation {
                            proxy.scrollTo(scrollPosition, anchor: .top)
                        }
//                        }
                    }
                }
                .listStyle(.grouped)
                .background(Color.screenBackground)
            }
        }
    }

    func sectionView(for section: GroupRozklad.State.Section) -> some View {
        Section(
            content: {
                ForEachStore(
                    self.store.scope(
                        state: \.sections[section.index].lessonCells,
                        action: GroupRozklad.Action.lessonCells(id:action:)
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
                GroupRozklad.State.Section.id(
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
                GroupRozklad.State.Section.id(
                    week: newSelectedWeek,
                    day: displayedDay
                ),
                anchor: .top
            )
        }
        selectedWeek = nil
    }

}
