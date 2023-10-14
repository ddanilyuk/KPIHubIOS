//
//  LessonDetailsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Foundation

struct LessonDetails: Reducer {
    struct State: Equatable {
        var lesson: Lesson
        var mode: LessonMode = .default
        @BindingState var isEditing: Bool = false
        @PresentationState var alert: AlertState<Action.Alert>?
    }
    
    enum Action: Equatable, BindableAction {
        case updateCurrentDate
        case updateLesson(Lesson)

        case alert(PresentationAction<Alert>)
        case view(View)
        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum View: Equatable {
            case onAppear
            case startEditingButtonTapped
            case endEditingButtonTapped
            case deleteLessonButtonTapped
            case editTeachersButtonTapped
            case editNamesButtonTapped
        }
        
        enum Alert: Equatable { 
            case deleteLessonConfirm
        }
        
        enum RouteAction: Equatable {
            case dismiss
            case editNames(_ lesson: Lesson)
            case editTeachers(_ lesson: Lesson)
        }
    }
    
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.currentDateService) var currentDateService
    @Dependency(\.analyticsService) var analyticsService
        
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
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
                            await send(.updateLesson(lesson))
                        }
                    },
                    .run { send in
                        for await _ in currentDateService.updatedStream().dropFirst() {
                            await send(.updateCurrentDate)
                        }
                    }
                )
                .cancellable(id: CancelID.onAppear, cancelInFlight: true)
                
            case .binding(\.$isEditing):
                if state.isEditing {
                    analyticsService.track(Event.LessonDetails.editTapped)
                }
                return .none

            case .updateCurrentDate:
                updateCurrentDate(state: &state)
                return .none
                
            case .view(.deleteLessonButtonTapped):
                state.alert = AlertState(
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
                return .none
                
            case .alert(.presented(.deleteLessonConfirm)):
                var lessons = rozkladServiceLessons.currentLessons()
                lessons.remove(id: state.lesson.id)
                rozkladServiceLessons.set(ClientValue<[Lesson]>(lessons.elements, commitChanges: true))
                analyticsService.track(Event.LessonDetails.removeLessonApply)
                return .send(.routeAction(.dismiss))

            case let .updateLesson(lesson):
                state.lesson = lesson
                return .none

            case .view(.editNamesButtonTapped):
                guard state.isEditing else {
                    return .none
                }
                return .send(.routeAction(.editNames(state.lesson)))

            case .view(.editTeachersButtonTapped):
                guard state.isEditing else {
                    return .none
                }
                return .send(.routeAction(.editTeachers(state.lesson)))
                
            case .view(.startEditingButtonTapped):
                state.isEditing = true
                return .none
                
            case .view(.endEditingButtonTapped):
                state.isEditing = false
                return .none
                
            case .alert(.dismiss):
                return .none

            case .binding:
                return .none

            case .routeAction:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
    
    private func updateCurrentDate(state: inout State) {
        let lessonID = state.lesson.id
        let currentLesson = currentDateService.currentLesson()
        let nextLessonID = currentDateService.nextLessonID()

        if let currentLesson = currentLesson, lessonID == currentLesson.lessonID {
            state.mode = .current(currentLesson.percent)
        } else if lessonID == nextLessonID {
            state.mode = .next
        } else {
            state.mode = .default
        }
    }
    
    enum CancelID {
        case onAppear
    }
}
