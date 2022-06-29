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
        case groupRozklad(GroupRozklad.State)
        case lessonDetails(LessonDetails.State)
        case editLessonNames(EditLessonNames.State)
        case editLessonTeachers(EditLessonTeachers.State)

    }

    // MARK: - Action handling

    enum Action: Equatable {
        case empty(EmptyScreen.Action)
        case groupPicker(GroupPicker.Action)
        case groupRozklad(GroupRozklad.Action)
        case lessonDetails(LessonDetails.Action)
        case editLessonNames(EditLessonNames.Action)
        case editLessonTeachers(EditLessonTeachers.Action)
    }

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Rozklad.Environment>.combine(
        GroupRozklad.reducer
            .pullback(
                state: /State.groupRozklad,
                action: /Action.groupRozklad,
                environment: {
                    GroupRozklad.Environment(
                        apiClient: $0.apiClient,
                        userDefaultsClient: $0.userDefaultsClient,
                        rozkladClient: $0.rozkladClient,
                        currentDateClient: $0.currentDateClient
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
                        userDefaultsClient: $0.userDefaultsClient,
                        rozkladClient: $0.rozkladClient
                    )
                }
            ),
        LessonDetails.reducer
            .pullback(
                state: /State.lessonDetails,
                action: /Action.lessonDetails,
                environment: {
                    LessonDetails.Environment(
                        userDefaultsClient: $0.userDefaultsClient,
                        rozkladClient: $0.rozkladClient,
                        currentDateClient: $0.currentDateClient
                    )
                }
            ),
        EditLessonNames.reducer
            .pullback(
                state: /State.editLessonNames,
                action: /Action.editLessonNames,
                environment: {
                    EditLessonNames.Environment(
                        userDefaultsClient: $0.userDefaultsClient,
                        rozkladClient: $0.rozkladClient
                    )
                }
            ),
        EditLessonTeachers.reducer
            .pullback(
                state: /State.editLessonTeachers,
                action: /Action.editLessonTeachers,
                environment: {
                    EditLessonTeachers.Environment(
                        userDefaultsClient: $0.userDefaultsClient,
                        rozkladClient: $0.rozkladClient
                    )
                }
            )
    )

}
