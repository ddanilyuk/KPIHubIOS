//
//  GroupLessonsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import IdentifiedCollections
import ComposableArchitecture
import Foundation

struct GroupLessons {

    // MARK: - State

    struct State: Equatable {
        
        var scheduleDays: [ScheduleDay]
        var lessonCells: [IdentifiedArrayOf<LessonCell.State>]

        init() {
            scheduleDays = [ScheduleDay](lessons: LessonResponse.mocked.map { Lesson(lessonResponse: $0) })
            lessonCells = scheduleDays.map { day in
                IdentifiedArrayOf(uniqueElements: day.lessons.map { LessonCell.State(lesson: $0) })
            }
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case lessonsResponse(Result<[Lesson], NSError>)

        case lessonCells(id: LessonResponse.ID, action: LessonCell.Action)

        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case openDetails(Lesson)
        }
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
    }

    // MARK: - Reducer

    static let coreReducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            if let lessons = environment.userDefaultsClient.get(for: .lessons) {
                state.scheduleDays = [ScheduleDay](lessons: lessons)
                state.lessonCells = state.scheduleDays.map { day in
                    IdentifiedArrayOf(uniqueElements: day.lessons.map { LessonCell.State(lesson: $0) })
                }
            }
            return .none

            let task: Effect<[Lesson], Error> = Effect.task {
                let result = try await environment.apiClient.decodedResponse(
                    for: .api(.group(
                        UUID(uuidString: "930dc61d-dc94-4213-947c-3158708732fd")!,
                        .lessons
                    )),
                    as: LessonsResponse.self
                )
                return result.value.lessons.map { Lesson(lessonResponse: $0) }
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.lessonsResponse)

        case let .lessonsResponse(.success(lessons)):
            environment.userDefaultsClient.set(lessons, for: .lessons)
            state.scheduleDays = [ScheduleDay](lessons: lessons)
            state.lessonCells = state.scheduleDays.map { day in
                IdentifiedArrayOf(uniqueElements: day.lessons.map { LessonCell.State(lesson: $0) })
            }
            return .none

        case let .lessonsResponse(.failure(error)):
            return .none

        case let .lessonCells(id, .onTap):
            guard
                let lessons = environment.userDefaultsClient.get(for: .lessons),
                let selectedLesson = IdentifiedArray(uniqueElements: lessons)[id: id]
            else {
                return .none
            }
            return Effect(value: .routeAction(.openDetails(selectedLesson)))

        case .routeAction:
            return .none

        case .lessonCells:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer<State, Action, Environment>.combine(
            (0..<12).map({ index in
                LessonCell.reducer
                    .forEach(
                        state: \State.lessonCells[index],
                        action: /Action.lessonCells,
                        environment: { _ in LessonCell.Environment() }
                    )
            })
        ),
        coreReducer
    )

}
