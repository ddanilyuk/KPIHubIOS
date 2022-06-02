//
//  GroupLessonsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import IdentifiedCollections
import ComposableArchitecture
import Foundation

extension GroupLessons.State.Section.Position {

    init(index: Int) {
        switch index {
        case (0..<6):
            week = .first
            day = Lesson.Day(rawValue: index + 1) ?? .monday

        case (6..<12):
            week = .second
            day = Lesson.Day(rawValue: index - 5) ?? .monday

        default:
            assertionFailure("Invalid index")
            week = .first
            day = .monday
        }
    }

}


extension Array where Element == GroupLessons.State.Section {

    static func combine<T, V>(_ firsts: [T], _ seconds: [V]) -> [(T, V)] {
        var result: [(T, V)] = []
        for first in firsts {
            for second in seconds {
                result.append((first, second))
            }
        }
        return result
    }

    init(lessons: IdentifiedArrayOf<Lesson>) {
        let emptyScheduleDays = Array.combine(Lesson.Week.allCases, Lesson.Day.allCases)
            .map {
                GroupLessons.State.Section(
                    position: .init(week: $0, day: $1),
                    lessonCells: []
                )
            }
        self = lessons.reduce(into: emptyScheduleDays) { partialResult, lesson in
            partialResult[
                ScheduleDay.index(
                    week: lesson.week,
                    day: lesson.day
                )
            ].lessonCells.append(LessonCell.State(lesson: lesson))
        }
    }

    init(lessons: [Lesson]) {
        let emptyScheduleDays = Array.combine(Lesson.Week.allCases, Lesson.Day.allCases)
            .map {
                GroupLessons.State.Section(
                    position: .init(week: $0, day: $1),
                    lessonCells: []
                )
            }
        self = lessons.reduce(into: emptyScheduleDays) { partialResult, lesson in
            partialResult[
                ScheduleDay.index(
                    week: lesson.week,
                    day: lesson.day
                )
            ].lessonCells.append(LessonCell.State(lesson: lesson))
        }
    }
}


struct GroupLessons {

    // MARK: - State

    struct State: Equatable {

        var lessons: IdentifiedArrayOf<Lesson>
        var sections: [Section] = []

        struct Section: Equatable, Identifiable {

            static func id(week: Lesson.Week, day: Lesson.Day) -> String {
                "\(Section.self)\(week.rawValue)\(day.rawValue)"
            }

            var id: String {
                Section.id(week: position.week, day: position.day)
            }

            var index: Int {
                position.index
            }

            let position: Position
            var lessonCells: IdentifiedArrayOf<LessonCell.State>

            struct Position: Equatable, Identifiable {
                let week: Lesson.Week
                let day: Lesson.Day

                static var count: Int {
                    return Lesson.Week.allCases.count * Lesson.Day.allCases.count
                }

                var id: Int {
                    return index
                }

                var index: Int {
                    Position.index(week: week, day: day)
                }

                static func index(week: Lesson.Week, day: Lesson.Day) -> Int {
                    (week.rawValue - 1) * 6 + (day.rawValue - 1)
                }
            }
        }

        init() {
//            scheduleDays = [ScheduleDay](lessons: LessonResponse.mocked.map { Lesson(lessonResponse: $0) })
//            lessonCells = scheduleDays.map { day in
//                IdentifiedArrayOf(uniqueElements: day.lessons.map { LessonCell.State(lesson: $0) })
//            }


            self.lessons = IdentifiedArray(uniqueElements: LessonResponse.mocked.map { Lesson(lessonResponse: $0) })
            self.sections = [Section](lessons: lessons)
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
                state.lessons = IdentifiedArray(uniqueElements: lessons)
                state.sections = [State.Section](lessons: lessons)
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
            state.lessons = IdentifiedArray(uniqueElements: lessons)
            state.sections = [State.Section](lessons: lessons)
            return .none

        case let .lessonsResponse(.failure(error)):
            return .none

        case let .lessonCells(id, .onTap):
            guard
                let selectedLesson = state.lessons[id: id]
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
            (0..<State.Section.Position.count).map({ index in
//                LessonCell.reducer
//                    .forEach(
//                        state: \State.lessonCells[index],
//                        action: /Action.lessonCells,
//                        environment: { _ in LessonCell.Environment() }
//                    )

                LessonCell.reducer
                    .forEach(
                        state: \State.sections[index].lessonCells,
                        action: /Action.lessonCells,
                        environment: { _ in LessonCell.Environment() }
                    )
            })
        ),
        coreReducer
    )

}
