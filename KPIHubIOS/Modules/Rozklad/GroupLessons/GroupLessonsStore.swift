//
//  GroupLessonsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import IdentifiedCollections
import ComposableArchitecture
import Foundation

extension Array where Element == GroupLessons.State.SectionState {

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
        let emptyScheduleDays = Array.combine(
            Lesson.Week.allCases,
            Lesson.Day.allCases
        ).map { GroupLessons.State.SectionState(week: $0, day: $1, lessonCells: []) }
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
        let emptyScheduleDays = Array.combine(
            Lesson.Week.allCases,
            Lesson.Day.allCases
        ).map { GroupLessons.State.SectionState(week: $0, day: $1, lessonCells: []) }
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
        
//        var scheduleDays: [ScheduleDay]
//        var lessonCells: [IdentifiedArrayOf<LessonCell.State>]

        var lessons: IdentifiedArrayOf<Lesson>
        var sectionStates: [SectionState] = []

        struct SectionState: Equatable, Identifiable {
            var id: String {
                SectionState.id(week: week, day: day)
            }
            var index: Int {
                SectionState.index(week: week, day: day)
            }

            static func id(week: Lesson.Week, day: Lesson.Day) -> String {
                "\(SectionState.self)\(week.rawValue)\(day.rawValue)"
            }

            let week: Lesson.Week
            let day: Lesson.Day
            
            static func index(week: Lesson.Week, day: Lesson.Day) -> Int {
                (week.rawValue - 1) * 6 + (day.rawValue - 1)
            }


            var lessonCells: IdentifiedArrayOf<LessonCell.State>
        }

        init() {
//            scheduleDays = [ScheduleDay](lessons: LessonResponse.mocked.map { Lesson(lessonResponse: $0) })
//            lessonCells = scheduleDays.map { day in
//                IdentifiedArrayOf(uniqueElements: day.lessons.map { LessonCell.State(lesson: $0) })
//            }


            self.lessons = IdentifiedArray(uniqueElements: LessonResponse.mocked.map { Lesson(lessonResponse: $0) })
            self.sectionStates = [SectionState](lessons: lessons)
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
                state.sectionStates = [State.SectionState](lessons: lessons)
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
            state.sectionStates = [State.SectionState](lessons: lessons)
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
            (0..<12).map({ index in
//                LessonCell.reducer
//                    .forEach(
//                        state: \State.lessonCells[index],
//                        action: /Action.lessonCells,
//                        environment: { _ in LessonCell.Environment() }
//                    )

                LessonCell.reducer
                    .forEach(
                        state: \State.sectionStates[index].lessonCells,
                        action: /Action.lessonCells,
                        environment: { _ in LessonCell.Environment() }
                    )
            })
        ),
        coreReducer
    )

}
