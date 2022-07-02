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

    /// Used for computing space after last section (for displaying week/day in right way )
    @State var lastSectionCellHeights: [CGFloat] = []

    @State var headerHeight: CGFloat = 0
    @State var headerBackgroundOpacity: CGFloat = 0

    let store: Store<GroupRozklad.State, GroupRozklad.Action>

    init(store: Store<GroupRozklad.State, GroupRozklad.Action>) {
        self.store = store

        UITableView.appearance().sectionHeaderTopPadding = 0
    }

    // MARK: - Views

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .top) {
                GroupRozkladHeaderView(
                    animation: animationModel,
                    groupName: viewStore.groupName,
                    selectedWeek: $selectedWeek,
                    selectedDay: $selectedDay,
                    displayedWeek: $displayedWeek,
                    displayedDay: $displayedDay,
                    headerBackgroundOpacity: $headerBackgroundOpacity,
                    currentWeek: viewStore.currentWeek,
                    currentDay: viewStore.currentDay
                )
                .modifier(RectModifier { rect in
                    headerHeight = rect.height - 4
                    animationModel.targetSize = headerHeight
                })
                .zIndex(1)

                scrollView
            }
            .ignoresSafeArea(.container, edges: .top)
            .navigationBarHidden(true)
            .onAppear {
                viewStore.send(.onAppear)
                animationModel.restore()
            }
            .onDisappear {
                viewStore.send(.onDisappear)
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
                                    height: max(
                                        0,
                                        geometryProxy.frame(in: .local).height - headerHeight - 44 - lastSectionCellHeights.reduce(0.0, +)
                                    )
                                )
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: headerHeight)
                    }
                    .overlay(alignment: .topTrailing) {
                        GroupRozkladScrollToView(
                            mode: .init(currentLesson: viewStore.state.currentLesson)
                        )
                        .onTapGesture {
                            viewStore.send(.scrollToNearest())
                        }
                        .offset(x: 0, y: headerHeight)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                    }
                    .onChange(of: selectedDay) { changeSelectedDay($0, proxy: proxy) }
                    .onChange(of: selectedWeek) { changeSelectedWeek($0, proxy: proxy) }
                    .onChange(of: viewStore.scrollTo) { newValue in
                        guard let scrollPosition = newValue else {
                            return
                        }
                        withAnimation {
                            proxy.scrollTo(scrollPosition, anchor: .top)
                        }
                        viewStore.send(.resetScrollTo)
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
            header: { sectionHeaderView(for: section) }
        )
        .id(section.id)
        .listRowInsets(EdgeInsets())
    }

    func sectionHeaderView(for section: GroupRozklad.State.Section) -> some View {
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
                if section.index == 0 {
                    updateHeaderBackgroundOpacity(offset: value)
                }
            }
        })
        .onDisappear {
            DispatchQueue.main.async {
                animationModel.setOffset(for: section.index, value: nil)
                if section.index == 0 {
                    headerBackgroundOpacity = 1
                }
            }
        }
    }

    // MARK: - Helpers

    func updateHeaderBackgroundOpacity(offset: CGFloat) {
        let minimumOpacityOffset = headerHeight
        let maximumOpacityOffset = headerHeight - 20

        switch offset {
        case (minimumOpacityOffset...):
            headerBackgroundOpacity = 0

        case (maximumOpacityOffset..<minimumOpacityOffset):
            headerBackgroundOpacity = 1 - ((offset - maximumOpacityOffset) / (20))

        default:
            headerBackgroundOpacity = 1
        }
    }

    func lastSectionOffsetModifiers(index: Int, height: CGFloat) {
        if lastSectionCellHeights[safe: index] == nil {
            lastSectionCellHeights.append(height)
        } else {
            lastSectionCellHeights[index] = height
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

// MARK: - Preview

struct GroupRozkladView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            GroupRozkladView(
                store: Store(
                    initialState: GroupRozklad.State(),
                    reducer: GroupRozklad.reducer,
                    environment: GroupRozklad.Environment(
                        apiClient: .failing,
                        userDefaultsClient: mockDependencies.userDefaults,
                        rozkladClient: .mock(),
                        currentDateClient: .mock()
                    )
                )
            )
            .navigationBarHidden(true)
        }
    }
}
