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

extension Rozklad.ScreenProvider {

    // MARK: - State handling

    enum State: Equatable, CoordinatorStateIdentifiable {

        static var module: Any.Type = Rozklad.self

        case groupLessons(GroupLessons.State)
        case lessonDetails(LessonDetails.State)
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case groupLessons(GroupLessons.Action)
        case lessonDetails(LessonDetails.Action)
    }

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Rozklad.Environment>.combine(
        GroupLessons.reducer
            .pullback(
                state: /State.groupLessons,
                action: /Action.groupLessons,
                environment: { _ in GroupLessons.Environment() }
            ),
        LessonDetails.reducer
            .pullback(
                state: /State.lessonDetails,
                action: /Action.lessonDetails,
                environment: { _ in LessonDetails.Environment() }
            )
    )

}
