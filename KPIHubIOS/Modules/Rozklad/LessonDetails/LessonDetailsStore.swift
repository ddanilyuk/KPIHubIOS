//
//  LessonDetailsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Foundation

struct LessonDetails: ReducerProtocol {

    // MARK: - State

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
        @BindableState var isEditing: Bool = false
        
        var alert: AlertState<Action>?
    }

    // MARK: - Action

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

    // MARK: - Environment
    
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.currentDateClient) var currentDateClient
    @Dependency(\.analyticsClient) var analyticsClient

    // MARK: - Reducer
    
    enum SubscriberCancelID { }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                let lessonID = state.lesson.id
                analyticsClient.track(Event.LessonDetails.appeared(
                    id: "\(lessonID)",
                    name: String(state.lesson.names.joined(separator: ", ").prefix(39))
                ))
                return Effect.merge(
                    Effect(value: .updateCurrentDate),
                    Effect.run { subscriber in
                        rozkladClientLessons.subject
                            .compactMap { $0[id: lessonID] }
                            .receive(on: DispatchQueue.main)
                            .sink { lesson in
                                subscriber.send(.updateLesson(lesson))
                            }
                    },
                    Effect.run { subscriber in
                        currentDateClient.updated
                            .dropFirst()
                            .receive(on: DispatchQueue.main)
                            .sink { _ in
                                subscriber.send(.updateCurrentDate)
                            }
                    }
                )
                .cancellable(id: SubscriberCancelID.self, cancelInFlight: true)
                
            case .binding(\.$isEditing):
                if state.isEditing {
                    analyticsClient.track(Event.LessonDetails.editTapped)
                }
                return .none

            case .updateCurrentDate:
                let lessonID = state.lesson.id
                let currentLesson = currentDateClient.currentLesson.value
                let nextLessonID = currentDateClient.nextLessonID.value

                if let currentLesson = currentLesson, lessonID == currentLesson.lessonID {
                    state.mode = .current(currentLesson.percent)
                } else if lessonID == nextLessonID {
                    state.mode = .next
                } else {
                    state.mode = .default
                }
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
                var lessons = rozkladClientLessons.subject.value
                lessons.remove(id: state.lesson.id)
                rozkladClientLessons.set(ClientValue<[Lesson]>(lessons.elements, commitChanges: true))
                analyticsClient.track(Event.LessonDetails.removeLessonApply)
                return Effect(value: .routeAction(.dismiss))
            
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
                return Effect(value: .routeAction(.editNames(state.lesson)))

            case .editTeachers:
                guard state.isEditing else {
                    return .none
                }
                return Effect(value: .routeAction(.editTeachers(state.lesson)))

            case .binding:
                return .none

            case .routeAction:
                return .none
            }
        }
    }

}
