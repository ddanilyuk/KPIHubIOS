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
        var showTeachers: Bool {
            !lesson.isTeachersEmpty
        }
        var showLocations: Bool {
            !lesson.isLocationsEmpty
        }
        var showType: Bool {
            !lesson.isTypeEmpty
        }
        @BindingState var isEditing: Bool = false
        
        var alert: AlertState<Action>?
    }
    
    enum Action: Equatable, BindableAction {
        case onAppear

        case updateCurrentDate
        case updateLesson(Lesson)

        case editNames
        case editTeachers
        case deleteLessonTapped
        case deleteLessonConfirm

        case dismissAlert
        case binding(BindingAction<State>)
        case routeAction(RouteAction)

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
                
            case .deleteLessonTapped:
                state.alert = AlertState(
                    title: {
                        TextState("Ви впевнені?")
                    },
                    actions: {
                        ButtonState(role: .destructive, action: .send(.deleteLessonConfirm)) {
                            TextState("Видалити")
                        }
                        ButtonState(role: .cancel, action: .send(.dismissAlert)) {
                            TextState("Назад")
                        }
                    },
                    message: {
                        TextState("Після видалення цей урок стане недоступний.")
                    }
                )
                return .none
                
            case .deleteLessonConfirm:
                var lessons = rozkladServiceLessons.currentLessons()
                lessons.remove(id: state.lesson.id)
                rozkladServiceLessons.set(ClientValue<[Lesson]>(lessons.elements, commitChanges: true))
                analyticsService.track(Event.LessonDetails.removeLessonApply)
                return .send(.routeAction(.dismiss))
            
            case .dismissAlert:
                state.alert = nil
                return .none

            case let .updateLesson(lesson):
                state.lesson = lesson
                return .none

            case .editNames:
                guard state.isEditing else {
                    return .none
                }
                return .send(.routeAction(.editNames(state.lesson)))

            case .editTeachers:
                guard state.isEditing else {
                    return .none
                }
                return .send(.routeAction(.editTeachers(state.lesson)))

            case .binding:
                return .none

            case .routeAction:
                return .none
            }
        }
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
