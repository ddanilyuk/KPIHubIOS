//
//  LessonDetailsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct LessonDetails: Reducer {
    @ObservableState
    public struct State: Equatable {
        var lesson: Lesson
        var mode: LessonMode = .default
        var isEditing = false
        @Presents var destination: Destination.State?
        
        init(lesson: Lesson) {
            self.lesson = lesson
        }
    }
    
    public enum Action: Equatable, BindableAction, ViewAction {
        case updateCurrentDate
        case updateLesson(Lesson)

        case destination(PresentationAction<Destination.Action>)
        case view(View)
        case binding(BindingAction<State>)
        
        public enum View: Equatable {
            case onAppear
            case startEditingButtonTapped
            case endEditingButtonTapped
            case deleteLessonButtonTapped
            case editTeachersButtonTapped
            case editNamesButtonTapped
        }
    }
    
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.currentDateService) var currentDateService
    @Dependency(\.analyticsService) var analyticsService
    @Dependency(\.dismiss) var dismiss

    public var body: some ReducerOf<Self> {
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
                
            case .binding(\.isEditing):
                if state.isEditing {
                    analyticsService.track(Event.LessonDetails.editTapped)
                }
                return .none

            case .updateCurrentDate:
                updateCurrentDate(state: &state)
                return .none
                
            case .view(.deleteLessonButtonTapped):
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
                
            case let .updateLesson(lesson):
                state.lesson = lesson
                return .none

            case .view(.editNamesButtonTapped):
                guard state.isEditing else {
                    return .none
                }
                state.destination = .editLessonNames(
                    EditLessonNames.State(lesson: state.lesson)
                )
                return .none

            case .view(.editTeachersButtonTapped):
                guard state.isEditing else {
                    return .none
                }
                state.destination = .editLessonTeachers(
                    EditLessonTeachers.State(lesson: state.lesson)
                )
                return .none
                
            case .view(.startEditingButtonTapped):
                state.isEditing = true
                return .none
                
            case .view(.endEditingButtonTapped):
                state.isEditing = false
                return .none
                
            case .binding:
                return .none
                
            case .destination(.presented(.alert(.deleteLessonConfirm))):
                var lessons = rozkladServiceLessons.currentLessons()
                lessons.remove(id: state.lesson.id)
                rozkladServiceLessons.set(ClientValue<[Lesson]>(lessons.elements, commitChanges: true))
                analyticsService.track(Event.LessonDetails.removeLessonApply)
                return .run { _ in
                    await dismiss()
                }
                
            case .destination(.presented(.editLessonNames)):
                return .none
            
            case .destination(.presented(.editLessonTeachers)):
                return .none
                
            case .destination(.dismiss):
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
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
    
    enum CancelID {
        case onAppear
    }
}

extension LessonDetails {
    @Reducer
    public struct Destination: Reducer {
        @ObservableState
        public enum State: Equatable {
            case alert(AlertState<Action.Alert>)
            case editLessonNames(EditLessonNames.State)
            case editLessonTeachers(EditLessonTeachers.State)
        }
        
        public enum Action: Equatable {
            case alert(Alert)
            case editLessonNames(EditLessonNames.Action)
            case editLessonTeachers(EditLessonTeachers.Action)
            
            public enum Alert: Equatable {
                case deleteLessonConfirm
            }
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.editLessonNames, action: \.editLessonNames) {
                EditLessonNames()
            }
            Scope(state: \.editLessonTeachers, action: \.editLessonTeachers) {
                EditLessonTeachers()
            }
        }
    }
}
