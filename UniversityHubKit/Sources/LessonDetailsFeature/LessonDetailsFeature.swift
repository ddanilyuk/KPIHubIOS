//
//  LessonDetailsFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import RozkladModels
import RozkladServices
import Services
@_exported import EditLessonNamesFeature
@_exported import EditLessonTeachersFeature

@Reducer
public struct LessonDetailsFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var lesson: RozkladLessonModel
        public var mode: RozkladLessonMode = .default
        public var isEditing = false
        @Presents public var destination: Destination.State?
        
        public init(lesson: RozkladLessonModel) {
            self.lesson = lesson
        }
    }
    
    public enum Action: Equatable, ViewAction {
        case view(View)
        case local(Local)
        case destination(PresentationAction<Destination.Action>)
        
        public enum View: Equatable {
            case onAppear
            case startEditingButtonTapped
            case endEditingButtonTapped
            case deleteLessonButtonTapped
            case editTeachersButtonTapped
            case editNamesButtonTapped
        }
        
        public enum Local: Equatable {
            case updateCurrentDate
            case updateLesson(RozkladLessonModel)
        }
    }
    
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.currentDateService) var currentDateService
    @Dependency(\.analyticsService) var analyticsService
    @Dependency(\.dismiss) var dismiss
    
    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .local(localAction):
                return handleLocalAction(state: &state, action: localAction)
                
            case let .destination(destinationAction):
                return handleDestinationAction(state: &state, action: destinationAction)
            }
        }
        .onChange(of: \.isEditing) { oldValue, newValue in
            Reduce { _, _ in
                if newValue { // TODO: Validate this
                    analyticsService.track(Event.LessonDetails.editTapped)
                }
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
            
    private enum CancelID {
        case onAppear
    }
}

// MARK: - ViewAction
extension LessonDetailsFeature {
    private func handleViewAction(
        state: inout State,
        action: Action.View
    ) -> Effect<Action> {
        switch action {
        case .onAppear:
            let lessonID = state.lesson.id
            analyticsService.track(Event.LessonDetails.appeared(
                id: "\(lessonID)",
                name: String(state.lesson.names.joined(separator: ", ").prefix(39))
            ))
            updateCurrentDate(state: &state)
            return .merge(
                .run { send in
                    for await lessons in rozkladServiceLessons.lessonsStream() {
                        guard let lesson = lessons[id: lessonID] else {
                            continue
                        }
                        await send(.local(.updateLesson(lesson)))
                    }
                },
                .run { send in
                    for await _ in currentDateService.updatedStream().dropFirst() {
                        await send(.local(.updateCurrentDate))
                    }
                }
            )
            .cancellable(id: CancelID.onAppear, cancelInFlight: true)
            
        case .startEditingButtonTapped:
            state.isEditing = true
            return .none
            
        case .endEditingButtonTapped:
            state.isEditing = false
            return .none
            
        case .deleteLessonButtonTapped:
            state.destination = .alert(
                AlertState(
                    title: {
                        TextState("Ви впевнені?")
                    },
                    actions: {
                        ButtonState(role: .destructive, action: .send(.deleteLessonConfirm)) {
                            TextState("Видалити")
                        }
                        ButtonState(role: .cancel) {
                            TextState("Назад")
                        }
                    },
                    message: {
                        TextState("Після видалення цей урок стане недоступний.")
                    }
                )
            )
            return .none
            
        case .editTeachersButtonTapped:
            guard state.isEditing else {
                return .none
            }
            state.destination = .editLessonTeachers(
                EditLessonTeachersFeature.State(lesson: state.lesson)
            )
            return .none
            
        case .editNamesButtonTapped:
            guard state.isEditing else {
                return .none
            }
            state.destination = .editLessonNames(
                EditLessonNamesFeature.State(lesson: state.lesson)
            )
            return .none
        }
    }
}

// MARK: - LocalAction
extension LessonDetailsFeature {
    private func handleLocalAction(
        state: inout State,
        action: Action.Local
    ) -> Effect<Action> {
        switch action {
        case .updateCurrentDate:
            updateCurrentDate(state: &state)
            return .none
            
        case let .updateLesson(lesson):
            state.lesson = lesson
            return .none
        }
    }
    
    private func updateCurrentDate(state: inout State) {
        let lessonID = state.lesson.id
        let currentLesson = currentDateService.currentLesson()
        let nextLessonID = currentDateService.nextLessonID()

        if let currentLesson, lessonID == currentLesson.lessonID {
            state.mode = .current(currentLesson.percent)
        } else if lessonID == nextLessonID {
            state.mode = .next
        } else {
            state.mode = .default
        }
    }
}

// MARK: - DestinationAction
extension LessonDetailsFeature {
    private func handleDestinationAction(
        state: inout State, 
        action: PresentationAction<Destination.Action>
    ) -> Effect<Action> {
        switch action {
        case .presented(.alert(.deleteLessonConfirm)):
            var lessons = rozkladServiceLessons.currentLessons()
            lessons.remove(id: state.lesson.id)
            rozkladServiceLessons.set(ClientValue<[RozkladLessonModel]>(lessons.elements, commitChanges: true))
            analyticsService.track(Event.LessonDetails.removeLessonApply)
            return .run { _ in
                await dismiss()
            }
            
         case .presented(.editLessonNames):
             return .none

         case .presented(.editLessonTeachers):
             return .none
            
        case .dismiss:
            return .none
        }
    }
}

extension LessonDetailsFeature {
    @Reducer
    public struct Destination: Reducer {
        @ObservableState
        public enum State: Equatable {
            case alert(AlertState<Action.Alert>)
            case editLessonNames(EditLessonNamesFeature.State)
            case editLessonTeachers(EditLessonTeachersFeature.State)
        }
        
        public enum Action: Equatable {
            case alert(Alert)
            case editLessonNames(EditLessonNamesFeature.Action)
            case editLessonTeachers(EditLessonTeachersFeature.Action)
            
            public enum Alert: Equatable {
                case deleteLessonConfirm
            }
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.editLessonNames, action: \.editLessonNames) {
                EditLessonNamesFeature()
            }
            Scope(state: \.editLessonTeachers, action: \.editLessonTeachers) {
                EditLessonTeachersFeature()
            }
        }
    }
}
