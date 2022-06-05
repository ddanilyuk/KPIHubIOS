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

        case empty(EmptyScreen.State)
        case groupPicker(GroupPicker.State)
        case groupLessons(GroupLessons.State)
        case lessonDetails(LessonDetails.State)
    }

    // MARK: - Action handling

    enum Action: Equatable {

        case empty(EmptyScreen.Action)
        case groupPicker(GroupPicker.Action)
        case groupLessons(GroupLessons.Action)
        case lessonDetails(LessonDetails.Action)
    }

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Rozklad.Environment>.combine(
        GroupLessons.reducer
            .pullback(
                state: /State.groupLessons,
                action: /Action.groupLessons,
                environment: {
                    GroupLessons.Environment(
                        apiClient: $0.apiClient,
                        userDefaultsClient: $0.userDefaultsClient
                    )
                }
            ),
        LessonDetails.reducer
            .pullback(
                state: /State.lessonDetails,
                action: /Action.lessonDetails,
                environment: {
                    LessonDetails.Environment(
                        userDefaultsClient: $0.userDefaultsClient
                    )
                }
            ),
        GroupPicker.reducer
            .pullback(
                state: /State.groupPicker,
                action: /Action.groupPicker,
                environment: {
                    GroupPicker.Environment(
                        apiClient: $0.apiClient,
                        userDefaultsClient: $0.userDefaultsClient
                    )
                }
            )
    )

}
