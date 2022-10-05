//
//  RozkladScreenProvider.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

extension Rozklad {

    struct ScreenProvider {}

}

extension Rozklad.ScreenProvider: ReducerProtocol {

    // MARK: - State handling

    enum State: Equatable, CoordinatorStateIdentifiable {

        static var module: Any.Type = Rozklad.self

        case groupPicker(GroupPicker.State)
        case groupRozklad(GroupRozklad.State)
        case lessonDetails(LessonDetails.State)
        case editLessonNames(EditLessonNames.State)
        case editLessonTeachers(EditLessonTeachers.State)
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case groupPicker(GroupPicker.Action)
        case groupRozklad(GroupRozklad.Action)
        case lessonDetails(LessonDetails.Action)
        case editLessonNames(EditLessonNames.Action)
        case editLessonTeachers(EditLessonTeachers.Action)
    }

    // MARK: - Reducer
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: /State.groupRozklad, action: /Action.groupRozklad) {
            GroupRozklad()
        }
        Scope(state: /State.groupPicker, action: /Action.groupPicker) {
            GroupPicker()
        }
        Scope(state: /State.lessonDetails, action: /Action.lessonDetails) {
            LessonDetails()
        }
        Scope(state: /State.editLessonNames, action: /Action.editLessonNames) {
            EditLessonNames()
        }
        Scope(state: /State.editLessonTeachers, action: /Action.editLessonTeachers) {
            EditLessonTeachers()
        }
    }

}
