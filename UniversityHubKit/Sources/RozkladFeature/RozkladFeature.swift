//
//  RozkladFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import RozkladModels
import RozkladServices
import GeneralServices

@Reducer
public struct RozkladFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var lessons: IdentifiedArrayOf<RozkladLessonModel>
        public var rows: IdentifiedArrayOf<RozkladRowProviderFeature.State>
        public var selectedID: String?
        public var currentLesson: CurrentDateService.CurrentLesson?
        public var nextLessonID: Int?
        public var header: RozkladHeaderFeature.State = .init(selectedLessonDay: nil)
                
        public init() {
            @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
            @Dependency(\.currentDateService) var currentDateService
            
            let currentLesson = currentDateService.currentLesson()
            let nextLessonID = currentDateService.nextLessonID()
            let lessons = rozkladServiceLessons.currentLessons()
            
            print("!!! less: \(lessons)")
            
            self.rows = RozkladFeature.generateRows(
                lessons: lessons,
                currentLesson: currentLesson,
                nextLessonID: nextLessonID
            )
            self.currentLesson = currentLesson
            self.nextLessonID = nextLessonID
            self.lessons = lessons
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case local(Local)
        case output(Output)

        @CasePathable
        public enum View: BindableAction {
            case onTask
            case binding(BindingAction<State>)
            case profileButtonTapped
            case currentIDChanged(String?)
            case header(RozkladHeaderFeature.Action)
            case rows(IdentifiedActionOf<RozkladRowProviderFeature>)
        }
        
        public enum Local: Equatable {
            case updateCurrentAndNextLesson
        }
        
        public enum Output: Equatable {
            case openProfile
            case openLessonDetails(RozkladLessonModel)
        }
    }
    
    @Dependency(\.currentDateService) var currentDateService
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Scope(state: \.header, action: \.view.header) {
            RozkladHeaderFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .local(localAction):
                return handleLocalAction(state: &state, action: localAction)
                
            case .output:
                return .none
            }
        }
        .forEach(\.rows, action: \.view.rows) {
            RozkladRowProviderFeature()
        }
    }
}

// MARK: - View
extension RozkladFeature {
    private func handleViewAction(state: inout State, action: Action.View) -> Effect<Action> {
        switch action {
        case .onTask:
            return .merge(
                .run { send in
                    for await _ in currentDateService.updatedStream() {
                        await send(.local(.updateCurrentAndNextLesson))
                    }
                }
            )
            
        case let .rows(rowAction):
            return handleViewRowsAction(state: &state, action: rowAction)
            
        case .profileButtonTapped:
            return .send(.output(.openProfile))
            
        case let .currentIDChanged(id):
            state.selectedID = id
            if let id, let row = state.rows[id: id] {
                state.header.selectedLessonDay = row.lessonDay
            } else {
                state.header.selectedLessonDay = .init(day: 1, week: 1)
            }
            return .none
            
        case let .header(headerAction):
            return handleHeaderAction(state: &state, action: headerAction)
            
        case .binding:
            return .none
        }
    }
    
    private func handleViewRowsAction(
        state: inout State,
        action: IdentifiedActionOf<RozkladRowProviderFeature>
    ) -> Effect<Action> {
        switch action {
        case let .element(id, .rozkladLesson(.output(outputAction))):
            switch outputAction {
            case .openLesson:
                guard
                    let row = state.rows[id: id],
                    let lesson = row.rozkladLesson?.lesson
                else {
                    return .none
                }
                return .send(.output(.openLessonDetails(lesson)))
            }
            
        case .element:
            return .none
        }
    }
    
    private func handleHeaderAction(
        state: inout State,
        action: RozkladHeaderFeature.Action
    ) -> Effect<Action> {
        switch action {
        case let .output(outputAction):
            switch outputAction {
            case let .selectDay(day):
                let row = state.rows.first(where: { row in
                    row.lessonDay.day == day && row.lessonDay.week == state.header.selectedLessonDay.week
                })
                guard let row else {
                    return .none
                }
                state.selectedID = row.id
                return .none
                
            case let .selectWeek(week):
                let row = state.rows.first(where: { row in
                    row.lessonDay.day == state.header.selectedLessonDay.day && row.lessonDay.week == week
                })
                guard let row else {
                    return .none
                }
                state.selectedID = row.id
                return .none
            }
            
        default:
            return .none
        }
    }
}

// MARK: - Local
extension RozkladFeature {
    private func handleLocalAction(state: inout State, action: Action.Local) -> Effect<Action> {
        switch action {
        case .updateCurrentAndNextLesson:
            let newLessons = rozkladServiceLessons.currentLessons()
            let newCurrentLesson = currentDateService.currentLesson()
            let newNextLessonID = currentDateService.nextLessonID()
            
            if let currentLesson = state.currentLesson,
               let newCurrentLesson,
               currentLesson.lessonID != newCurrentLesson.lessonID {
                state.selectedID = newCurrentLesson.lessonID.stringValue
            }
            
            state.currentLesson = newCurrentLesson
            state.nextLessonID = newNextLessonID
            state.rows = Self.generateRows(
                lessons: newLessons,
                currentLesson: newCurrentLesson,
                nextLessonID: newNextLessonID
            )
            return .none
        }
    }
}

extension RozkladFeature {
    static func generateRows(
        lessons: IdentifiedArrayOf<RozkladLessonModel>,
        currentLesson: CurrentDateService.CurrentLesson?,
        nextLessonID: Int?
    ) -> IdentifiedArrayOf<RozkladRowProviderFeature.State> {
        lessons.reduce(into: []) { partialResult, lesson in
            let status: RozkladLessonFeature.State.Status
            if let currentLesson, currentLesson.lessonID == lesson.id {
                status = .current(currentLesson.percent)
            } else if let nextLessonID, nextLessonID == lesson.id {
                status = .next
            } else {
                status = .idle
            }
            
            let lessonFeatureState = RozkladRowProviderFeature.State.rozkladLesson(
                RozkladLessonFeature.State(
                    lesson: lesson,
                    status: status
                )
            )
            if let last = partialResult.last, last.lessonDay.day == lesson.day && last.lessonDay.week == lesson.week {
                partialResult.append(lessonFeatureState)
            } else {
                partialResult.append(
                    .sectionHeader(RozkladSectionHeaderFeature.State(day: lesson.day, week: lesson.week))
                )
                partialResult.append(lessonFeatureState)
            }
        }
    }
}
