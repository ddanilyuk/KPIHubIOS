//
//  GroupRozkladStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import IdentifiedCollections
import ComposableArchitecture
import Foundation

struct GroupRozklad: Reducer {
    struct State: Equatable {
        var currentDay: Lesson.Day?
        var currentWeek: Lesson.Week = .first
        var currentLesson: CurrentLesson?
        var nextLessonID: Lesson.ID?

        var groupName: String = ""
        var lessons: IdentifiedArrayOf<Lesson> = []
        var sections: IdentifiedArrayOf<GroupRozkladSectionFeature.State> = []

        var isAppeared = false

        @BindingState var needToScrollOnAppear = false
        @BindingState var scrollTo: Lesson.ID?
//        @BindingState var scrolledDay: GroupRozklad.State.Section?

        // Animations
        @BindingState var position: RozkladPosition? = .init(week: .first, day: .monday)
        
//        @BindingState var lastShownElement: LastShownElement?
//        var offsets: [CGFloat?] = Array(
//            repeating: nil,
//            count: GroupRozklad.State.Section.Position.count
//        )

//        var lessonCells: IdentifiedArrayOf<LessonCell.State> {
//            get {
//                sections
//                    .map { $0.lessonCells }
//                    .reduce(into: [], { $0.append(contentsOf: $1.elements) })
//            }
//            set {
//                lessons = IdentifiedArrayOf(uniqueElements: newValue.map { $0.lesson })
//                sections = [State.Section](lessons: lessons)
//            }
//        }
//
//        init() {
//            self.lessons = []
//            self.sections = [Section](lessons: [])
//        }
    }
    
    enum Action: Equatable {
        case onDisappear

        case updateLessons(IdentifiedArrayOf<Lesson>)
        case updateCurrentDate

        case resetScrollTo

        case sections(id: GroupRozkladSectionFeature.State.ID, action: GroupRozkladSectionFeature.Action)
//        case lessonCells(id: LessonResponse.ID, action: LessonCell.Action)
        case routeAction(RouteAction)
        
        case setOffset(index: Int, value: CGFloat?, headerHeight: CGFloat)
        case view(View)
        
        enum RouteAction: Equatable {
            case openDetails(Lesson)
        }
        
        enum View: Equatable, BindableAction {
            case onAppear
            case scrollToNearest
            
            case selectWeek(Lesson.Week)
            case selectDay(Lesson.Day?)
            
            case binding(BindingAction<State>)
        }        
    }
    
    @Dependency(\.rozkladServiceState) var rozkladServiceState
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.currentDateService) var currentDateService
    @Dependency(\.analyticsService) var analyticsService
    
    var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
        Reduce<State, Action> { state, action in
            switch action {
            case .view(.onAppear):
//            case .onAppear:
                state.isAppeared = true
                analyticsService.track(Event.Rozklad.groupRozkladAppeared)
                updateLessons(to: rozkladServiceLessons.currentLessons(), state: &state)
                if state.needToScrollOnAppear {
                    scrollToNearest(state: &state)
                    state.needToScrollOnAppear = false
                }
                return .merge(
                    updateCurrentDate(state: &state),
                    .run { send in
                        for await lessons in rozkladServiceLessons.lessonsStream().dropFirst() {
                            await send(.updateLessons(lessons))
                        }
                    },
                    .run { send in
                        for await _ in currentDateService.updatedStream().dropFirst() {
                            await send(.updateCurrentDate)
                        }
                    }
                )
                .cancellable(id: CancelID.onAppear, cancelInFlight: true)
                
            case let .view(.selectDay(day)):
                state.position = state.sections.first { section in
                    section.position.day == day && state.position?.week == section.position.week
                }?.position
                return .none
                
            case let .view(.selectWeek(week)):
                state.position = state.sections.first { section in
                    section.position.week == week && state.position?.day == section.position.day
                }?.position
                return .none
                
            case .view(.scrollToNearest):
                scrollToNearest(state: &state)
                return .none

            case .onDisappear:
                state.isAppeared = false
                return .none

            case .updateCurrentDate:
                return updateCurrentDate(state: &state)

            case let .updateLessons(lessons):
                updateLessons(to: lessons, state: &state)
                return .none

            case .resetScrollTo:
                state.scrollTo = nil
                return .none
                
            case let .sections(id, action):
                return .none
//            case let .lessonCells(id, .onTap):
//                guard
//                    let selectedLesson = state.lessons[id: id]
//                else {
//                    return .none
//                }
//                return .send(.routeAction(.openDetails(selectedLesson)))
                
            case let .setOffset(index, value, headerHeight):
//                guard
//                    state.isAppeared,
//                    state.offsets[index] != value
//                else {
//                    return .none
//                }
//                state.offsets[index] = value
//                let offset = state.offsets
//                let lastShownElement = state.lastShownElement
                return .none
//                return .run { send in
//                    let calculatedIndex = await calculateIndex(
//                        headerHeight: headerHeight,
//                        offsets: offset,
//                        lastShownElement: lastShownElement
//                    ) { lastShownElement in
//                        await send(.binding(.set(\.$lastShownElement, lastShownElement)))
//                    }
//                    let newPosition = GroupRozklad.State.Section.Position(
//                        index: min(max(0, calculatedIndex), 11)
//                    )
//                    await send(.binding(.set(\.$position, newPosition)))
//                }
//                .cancellable(id: CancelID.setOffset, cancelInFlight: true)

            case .routeAction:
                return .none

//            case .lessonCells:
//                return .none

            case .view(.binding):
                return .none
            }
        }
        .forEach(\.sections, action: /Action.sections) {
            GroupRozkladSectionFeature()
        }
//        .forEach(\State.lessonCells, action: /Action.lessonCells) {
//            LessonCell()
//        }
    }
    
    private func updateCurrentDate(state: inout State) -> Effect<Action> {
        let oldCurrentLesson = state.currentLesson
        let oldNextLessonID = state.nextLessonID
        state.currentDay = currentDateService.currentDay()
        state.currentWeek = currentDateService.currentWeek()
        state.currentLesson = currentDateService.currentLesson()
        state.nextLessonID = currentDateService.nextLessonID()
        let some = [GroupRozkladSectionFeature.State](
            lessons: state.lessons,
            currentLesson: state.currentLesson,
            nextLesson: state.nextLessonID
        )
        state.sections = IdentifiedArray(uniqueElements: some)
        if oldCurrentLesson?.lessonID != state.currentLesson?.lessonID || oldNextLessonID != state.nextLessonID {
            if state.isAppeared {
                return .run { send in
                    try await Task.sleep(for: .seconds(0.3))
                    await send(.view(.scrollToNearest))
                }
            } else {
                state.needToScrollOnAppear = true
                return .none
            }
        } else {
            return .none
        }
    }
    
    private func scrollToNearest(state: inout State) {
        let scrollTo = state.currentLesson?.lessonID ?? state.nextLessonID
        state.scrollTo = scrollTo
    }
    
    private func updateLessons(to lessons: IdentifiedArrayOf<Lesson>, state: inout State) {
        state.groupName = rozkladServiceState.group()?.name ?? "-"
        state.lessons = lessons
        let some = [GroupRozkladSectionFeature.State](
            lessons: state.lessons,
            currentLesson: state.currentLesson,
            nextLesson: state.nextLessonID
        )
        state.sections = IdentifiedArray(uniqueElements: some)
    }
    
    enum CancelID {
        case onAppear
        case setOffset
    }
}

func calculateIndex(
    headerHeight: CGFloat,
    offsets: [CGFloat?],
    lastShownElement: LastShownElement?,
    onChangeLastShownElement: @escaping (LastShownElement) async -> Void
) async -> Int {
    let target = headerHeight + 1
    let offsets = offsets
    let numberOfElements = offsets.compactMap { $0 }.count

    func compareWithTarget(element: CGFloat, index: Int) -> Int {
        element < target ? index : index - 1
    }
    
    switch numberOfElements {
    case 1:
        let index = offsets.firstIndex(where: { $0 != nil })!
        let element = offsets[index]!
        await onChangeLastShownElement(LastShownElement(index: index, value: element))
        return compareWithTarget(element: element, index: index)

    case 0:
        guard let lastShownElement else {
            return 0
        }
        return compareWithTarget(element: lastShownElement.value, index: lastShownElement.index)

    default:
        let index = offsets.firstIndex(where: { $0 != nil })!
        let element = offsets[index]!
        if element < target {
            return offsets.lastIndex(where: { $0 != nil ? $0! < target : false }) ?? index
        } else {
            return index - 1
        }
    }
}

struct LastShownElement: Equatable {
    var index: Int
    var value: CGFloat
}
