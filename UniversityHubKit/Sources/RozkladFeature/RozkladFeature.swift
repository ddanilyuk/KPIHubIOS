//
//  RozkladFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import RozkladModels
import Services

@Reducer
public struct RozkladFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var lessons: IdentifiedArrayOf<RozkladLessonModel>
        public var rows: IdentifiedArrayOf<RozkladRowProviderFeature.State>
        public var lessonDay: LessonDay?
        
        public init() {
            @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
            
            let models = rozkladServiceLessons.currentLessons().map { RozkladLessonModel(lesson: $0) }
            lessons = IdentifiedArray(uniqueElements: models)
            
            let array = models.enumerated().map { index, lesson in
                RozkladLessonFeature.State(lesson: lesson, status: index == 1 ? .current : .idle)
            }
            
            let result: [RozkladRowProviderFeature.State] = models.reduce(into: []) { partialResult, lesson in
                if let last = partialResult.last, last.lessonDay.day == lesson.day && last.lessonDay.week == lesson.week {
                    partialResult.append(
                        .rozkladLesson(RozkladLessonFeature.State(lesson: lesson))
                    )
                } else {
                    partialResult.append(
                        .sectionHeader(RozkladSectionHeaderFeature.State(day: lesson.day, week: lesson.week))
                    )
                    partialResult.append(
                        .rozkladLesson(RozkladLessonFeature.State(lesson: lesson))
                    )
                }
            }
            
            rows = IdentifiedArray(uniqueElements: result)
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case local(Local)
        case output(Output)

        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case profileButtonTapped
            case rows(IdentifiedActionOf<RozkladRowProviderFeature>)
        }
        
        public enum Local: Equatable {
            
        }
        
        public enum Output: Equatable {
            case openProfile
            case openLessonDetails(RozkladLessonModel)
        }
    }
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
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
        case let .rows(rowAction):
            return handleViewRowsAction(state: &state, action: rowAction)
            
        case .profileButtonTapped:
            return .send(.output(.openProfile))
            
        case .binding:
            print("!!! binding")
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
                // TODO: Fix
                guard let model = state.lessons[id: Int(id) ?? 0] else {
                    return .none
                }
                return .send(.output(.openLessonDetails(model)))
            }
            
        case .element:
            return .none
        }
    }
}

// MARK: - Local
extension RozkladFeature {
    private func handleLocalAction(state: inout State, action: Action.Local) -> Effect<Action> {
        return .none
    }
}
