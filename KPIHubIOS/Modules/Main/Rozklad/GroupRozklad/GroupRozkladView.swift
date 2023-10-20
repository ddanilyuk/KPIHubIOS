//
//  GroupRozkladView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct GroupRozkladView: View {
    struct ViewState: Equatable {
//        var sections: [GroupRozklad.State.Section] = []
        @BindingViewState var position: RozkladPosition?
        @BindingViewState var scrollTo: Lesson.ID?
        var currentLesson: CurrentLesson?
        
        init(_ state: BindingViewStore<GroupRozklad.State>) {
//            sections = state.sections
            _position = state.$position
            _scrollTo = state.$scrollTo
            currentLesson = state.currentLesson
        }
    }

//    @State var selectedWeek: Lesson.Week?
//    @State var selectedDay: Lesson.Day?
//    @State var displayedWeek: Lesson.Week = .first
//    @State var displayedDay: Lesson.Day = .monday

    /// Used for computing space after last section (for displaying week/day in right way)
//    @State var lastSectionCellHeights: [CGFloat] = []
//    @State var headerHeight: CGFloat = 0
    @State var firstSectionOffset: CGFloat = 0
    @State var lastSectionHeight: CGFloat = 0
//    @State var headerBackgroundOpacity: CGFloat = 0
    
    private let store: StoreOf<GroupRozklad>
    @ObservedObject private var viewStore: ViewStore<ViewState, GroupRozklad.Action.View>

    init(store: StoreOf<GroupRozklad>) {
        self.store = store
        self.viewStore = ViewStore(
            store, 
            observe: ViewState.init,
            send: { .view($0) }
        )
        UITableView.appearance().sectionHeaderTopPadding = 0
    }

    // MARK: - Views
    
    var body: some View {
        VStack(spacing: 0) {
            GroupRozkladHeaderView(store: store, backgroundOpacity: 1)

            scrollView
        }
        .animation(.default, value: viewStore.position)
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarHidden(true)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
    
    var scrollView: some View {
        GeometryReader { geometryProxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEachStore(
                        store.scope(
                            state: \.sections,
                            action: { .sections(id: $0, action: $1) }
                        )
                    ) { sectionStore in
                        GroupRozkladSectionView(store: sectionStore)
                            .background(
                                Color.red.opacity(0.3).overlay {
                                    GeometryReader { proxy in
                                        Color.clear
                                            .onAppear {
                                                print("!!!!! appearing \(sectionStore.withState { $0.id })")
                                                guard sectionStore.withState { $0.index } == 0 else {
                                                    return
                                                }
                                                print("!!! onAppear")
                                            }
                                            .onDisappear {
                                                print("!!!!! onDisappear \(sectionStore.withState { $0.id })")
                                            }
                                            .onChange(of: proxy.bounds(of: .scrollView)?.minY) { oldValue, newValue in
                                                guard sectionStore.withState { $0.index } == 0 else {
                                                    return
                                                }
                                                print("!!! new Value: \(newValue) | \(oldValue)")
                                            }
                                    }
                                }
                            )

//                            .if(store.withState { $0.index } == 0) { view in
//                                view
//                                    .background(Color.red)
////                                    .modifier(
////                                        RectModifier(coordinateSpace: .scrollView) {
////                                            firstSectionOffset = $0.minY
////                                            print("!!! firstSectionOffset \($0.minY)")
////                                        }
////                                    )
//                            }
//                            .if(store.withState { $0.index } == 11) { view in
//                                view
//                                    .modifier(
//                                        RectModifier(coordinateSpace: .scrollView) {
//                                            print("!!! lastSectionHeight \($0.height)")
//                                            lastSectionHeight = $0.height
//                                        }
//                                    )
//                            }
                    }
                }
                .onAppear {
                    print("!!! lazy stack appear")
                }
                
                Rectangle()
                    .fill(Color.screenBackground)
                    .overlay {
                        VStack {
                            Text(geometryProxy.size.height, format: .number)
                            
                            Text(lastSectionHeight, format: .number)
                        }
                    }
                    .frame(
                        height: max(
                            0,
                            geometryProxy.size.height - lastSectionHeight
                        )
                    )
            }
            .scrollPosition(id: viewStore.$position, anchor: .top)
            .scrollTargetLayout()
            .overlay(alignment: .topTrailing) {
                GroupRozkladScrollToView(
                    mode: .init(currentLesson: viewStore.currentLesson)
                )
                .onTapGesture {
                    viewStore.send(.scrollToNearest)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
            }
        }
    }

//    var body: some View {
//        ZStack(alignment: .top) {
//            WithViewStore(
//                store,
//                observe: GroupRozkladHeaderView.ViewState.init,
//                content: { viewStore in
//                    GroupRozkladHeaderView(
//                        viewStore: viewStore,
//                        displayedWeek: $displayedWeek,
//                        displayedDay: $displayedDay,
//                        headerBackgroundOpacity: $headerBackgroundOpacity,
//                        selectWeek: { selectedWeek = $0 },
//                        selectDay: { selectedDay = $0 }
//                    )
//                }
//            )
//            .modifier(RectModifier { rect in
//                headerHeight = rect.height - 4
//            })
//            .zIndex(1)
//
//            scrollView
//        }
//        .ignoresSafeArea(.container, edges: .top)
//        .navigationBarHidden(true)
//        .onAppear {
//            viewStore.send(.onAppear)
//        }
////        .onDisappear {
////            viewStore.send(.onDisappear)
////        }
//    }

//    private var scrollView: some View {
//        GeometryReader { geometryProxy in
//            ScrollViewReader { proxy in
//                _scrollView(geometryProxy: geometryProxy)
//                    .safeAreaInset(edge: .top, spacing: 0) {
//                        Rectangle()
//                            .fill(Color.clear)
//                            .frame(height: headerHeight)
//                    }
//                    .overlay(alignment: .topTrailing) {
//                        GroupRozkladScrollToView(
//                            mode: .init(currentLesson: viewStore.currentLesson)
//                        )
//                        .onTapGesture {
//                            viewStore.send(.scrollToNearest)
//                        }
//                        .offset(x: 0, y: headerHeight)
//                        .padding(.top, 8)
//                        .padding(.horizontal, 16)
//                    }
//                    .onChange(of: selectedDay) { changeSelectedDay($0, proxy: proxy) }
//                    .onChange(of: selectedWeek) { changeSelectedWeek($0, proxy: proxy) }
//                    .onChange(of: viewStore.scrollTo) { newValue in
//                        guard let scrollPosition = newValue else {
//                            return
//                        }
//                        withAnimation {
//                            proxy.scrollTo(scrollPosition, anchor: .top)
//                        }
//                        viewStore.send(.resetScrollTo)
//                    }
//            }
//            .listStyle(.grouped)
//            .background(Color.screenBackground)
//        }
//    }
    
    // TODO: Fix
//    @ViewBuilder
//    private func _scrollView(geometryProxy: GeometryProxy) -> some View {
//        ScrollView(.vertical, showsIndicators: false) {
//            LazyVStack(alignment: .leading, spacing: 0) {
//                ForEach(viewStore.sections, id: \.id) { section in
//                    sectionView(for: section)
//                }
//                Rectangle()
//                    .fill(Color.screenBackground)
//                    .frame(
//                        height: max(
//                            0,
//                            geometryProxy.frame(in: .local).height - headerHeight - 44 - lastSectionCellHeights.reduce(0.0, +)
//                        )
//                    )
//            }
//        }
//    }

//    private func sectionView(for section: GroupRozklad.State.Section) -> some View {
//        Section(
//            content: {
//                ForEachStore(
//                    store.scope(
//                        state: \.sections[section.index].lessonCells,
//                        action: GroupRozklad.Action.lessonCells(id:action:)
//                    ),
//                    content: { store in
//                        LessonCellView(store: store)
//                            .if(section.index == 11) { view in
//                                view.modifier(RectModifier { frame in
//                                    lastSectionOffsetModifiers(
//                                        index: store.withState { $0.lesson.position.rawValue },
//                                        height: frame.height
//                                    )
//                                })
//                            }
//                    }
//                )
//            },
//            header: { sectionHeaderView(for: section) }
//        )
//        .id(section.id)
//        .listRowInsets(EdgeInsets())
//    }

//    private func sectionHeaderView(for section: GroupRozklad.State.Section) -> some View {
//        HStack {
//            let day = section.position.day.fullDescription
//            let week = section.position.week.description
//            Text("\(day). \(week)")
//                .font(.system(.headline))
//                .foregroundColor(.primary)
//                .padding(.horizontal)
//                .padding(.top)
//                .textCase(nil)
//                .listRowInsets(EdgeInsets())
//                .listRowSeparator(.hidden)
//
//            Spacer()
//        }
//        .frame(height: 44)
//        .modifier(OffsetModifier { value in
//            viewStore.send(
//                .setOffset(index: section.index, value: value, headerHeight: headerHeight)
//            )
//            if section.index == 0 {
//                updateHeaderBackgroundOpacity(offset: value)
//            }
//        })
//        .onDisappear {
//            viewStore.send(
//                .setOffset(index: section.index, value: nil, headerHeight: headerHeight)
//            )
//            if section.index == 0 {
//                headerBackgroundOpacity = 1
//            }
//        }
//    }

    // MARK: - Helpers
    
//    var headerBackgroundOpacity: CGFloat {
//        let headerHeight: CGFloat = 80
//        let minimumOpacityOffset = headerHeight
//        let maximumOpacityOffset = headerHeight - 20
//
//        switch firstSectionOffset {
//        case (minimumOpacityOffset...):
//            return 0
//
//        case (maximumOpacityOffset..<minimumOpacityOffset):
//            return 1 - ((firstSectionOffset - maximumOpacityOffset) / (20))
//
//        default:
//            return 1
//        }
//    }

//    private func updateHeaderBackgroundOpacity(offset: CGFloat) {
//        let minimumOpacityOffset = headerHeight
//        let maximumOpacityOffset = headerHeight - 20
//
//        switch offset {
//        case (minimumOpacityOffset...):
//            headerBackgroundOpacity = 0
//
//        case (maximumOpacityOffset..<minimumOpacityOffset):
//            headerBackgroundOpacity = 1 - ((offset - maximumOpacityOffset) / (20))
//
//        default:
//            headerBackgroundOpacity = 1
//        }
//    }

//    private func lastSectionOffsetModifiers(index: Int, height: CGFloat) {
//        if lastSectionCellHeights[safe: index] == nil {
//            lastSectionCellHeights.append(height)
//        } else {
//            lastSectionCellHeights[index] = height
//        }
//    }

//    private func changeSelectedDay(_ newValue: Lesson.Day?, proxy: ScrollViewProxy) {
//        guard let newSelectedDay = newValue else {
//            return
//        }
//        withAnimation {
//            proxy.scrollTo(
//                GroupRozklad.State.Section.id(
//                    week: displayedWeek,
//                    day: newSelectedDay
//                ),
//                anchor: .top
//            )
//        }
//        selectedDay = nil
//    }

//    private func changeSelectedWeek(_ newValue: Lesson.Week?, proxy: ScrollViewProxy) {
//        guard let newSelectedWeek = newValue else {
//            return
//        }
//        withAnimation {
//            proxy.scrollTo(
//                GroupRozklad.State.Section.id(
//                    week: newSelectedWeek,
//                    day: displayedDay
//                ),
//                anchor: .top
//            )
//        }
//        selectedWeek = nil
//    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GroupRozkladView(
            store: Store(initialState: GroupRozklad.State()) {
                GroupRozklad()
            }
        )
        .navigationBarHidden(true)
    }
}

struct GroupRozkladSectionFeature: Reducer {
    struct State: Equatable, Identifiable {
        var lessonCells: IdentifiedArrayOf<LessonCell.State>
        let position: RozkladPosition
        
        static func id(week: Lesson.Week, day: Lesson.Day) -> String {
            "\(Self.self)\(week.rawValue)\(day.rawValue)"
        }

        var id: String {
            Self.id(week: position.week, day: position.day)
        }
        
        var index: Int {
            position.index
        }
        
//        var addSpace: Bool {
//            position.index == 11
//        }
    }
    
    enum Action: Equatable { 
        case lessonCells(id: LessonCell.State.ID, action: LessonCell.Action)
    }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
            .forEach(\.lessonCells, action: /Action.lessonCells) {
                LessonCell()
            }
    }
}

struct GroupRozkladSectionView: View {
    private let store: StoreOf<GroupRozkladSectionFeature>
    @ObservedObject private var viewStore: ViewStoreOf<GroupRozkladSectionFeature>
//    let scrollViewBoundsHeight: CGFloat
    
    init(store: StoreOf<GroupRozkladSectionFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        Section(
            content: {
                ForEachStore(
                    store.scope(
                        state: \.lessonCells,
                        action: { .lessonCells(id: $0, action: $1) }
                    ),
                    content: { store in
                        LessonCellView(store: store)
//                            .if(section.index == 11) { view in
//                                view.modifier(RectModifier { frame in
//                                    lastSectionOffsetModifiers(
//                                        index: store.withState { $0.lesson.position.rawValue },
//                                        height: frame.height
//                                    )
//                                })
//                            }
                    }
                )
            },
            header: { header }
        )
        .id(viewStore.position)
        .listRowInsets(EdgeInsets())
//        .if(viewStore.addSpace) { view in
//            view
//                .padding(.bottom, calculatePadding)
//        }
//        .overlay(
//            GeometryReader { proxy in
////                proxy.frame(in: .scrollView).
////                if let distanceFromTop = proxy.bounds(of: .scrollView)?.maxY {
////                    Text(distanceFromTop, format: .number)
////                }
////                
////                if let distanceFromTop = proxy.bounds(of: .scrollView)?.minY {
////                    Text(distanceFromTop, format: .number)
////                }
//                Text(proxy.frame(in: .scrollView).minY, format: .number)
//
////                proxy.size.
////                proxy.
////                Text(proxy.frame(in: .scrollView).height, format: .number)
//            }
//        )
    }
    
    var calculatePadding: CGFloat {
        0
    }
    
    var header: some View {
        HStack {
            let day = viewStore.position.day.fullDescription
            let week = viewStore.position.week.description
            Text("\(day). \(week)")
                .font(.system(.headline))
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top)
                .textCase(nil)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            Spacer()
        }
    }
}

// MARK: - Section

//extension GroupRozklad.State {
//    struct Section: Equatable, Identifiable {
//    }
//}

// MARK: - Section.Position

struct RozkladPosition: Equatable, Identifiable, Hashable {
    static var count: Int {
        Lesson.Week.allCases.count * Lesson.Day.allCases.count
    }

    static func index(week: Lesson.Week, day: Lesson.Day) -> Int {
        (week.rawValue - 1) * Lesson.Day.allCases.count + (day.rawValue - 1)
    }

    let week: Lesson.Week
    let day: Lesson.Day

    var id: Int {
        index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var index: Int {
        Self.index(week: week, day: day)
    }
}


// MARK: - Section.Position init

extension RozkladPosition {
    init(index: Int) {
        switch index {
        case (0..<6):
            week = .first
            day = Lesson.Day(rawValue: index + 1) ?? .monday

        case (6..<12):
            week = .second
            day = Lesson.Day(rawValue: index - 5) ?? .monday

        default:
            assertionFailure("Invalid index")
            week = .first
            day = .monday
        }
    }
}

// MARK: - Array + GroupRozklad.State.Section

extension Array where Element == GroupRozkladSectionFeature.State {
    static func combine<T, V>(_ firsts: [T], _ seconds: [V]) -> [(T, V)] {
        var result: [(T, V)] = []
        for first in firsts {
            for second in seconds {
                result.append((first, second))
            }
        }
        return result
    }

    init(
        lessons: IdentifiedArrayOf<Lesson>,
        currentLesson: CurrentLesson? = nil,
        nextLesson: Lesson.ID? = nil
    ) {
        let emptySections = Self.combine(Lesson.Week.allCases, Lesson.Day.allCases)
            .map { week, day in
                GroupRozkladSectionFeature.State(
                    lessonCells: [],
                    position: .init(week: week, day: day)
                )
            }
        self = lessons.reduce(into: emptySections) { partialResult, lesson in
            var mode: LessonMode = .default
            if lesson.id == currentLesson?.lessonID {
                mode = .current(currentLesson?.percent ?? 0)
            } else if lesson.id == nextLesson {
                mode = .next
            }
            let lessonState = LessonCell.State(
                lesson: lesson,
                mode: mode
            )
            partialResult[
                RozkladPosition.index(
                    week: lesson.week,
                    day: lesson.day
                )
            ].lessonCells.append(lessonState)
        }
    }
}
