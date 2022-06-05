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

        var groupName: String = ""
        var lessons: IdentifiedArrayOf<Lesson> = []
        var sections: [Section] = []

        struct Section: Equatable, Identifiable {

            static func id(week: Lesson.Week, day: Lesson.Day) -> String {
                "\(Section.self)\(week.rawValue)\(day.rawValue)"
            }

            let position: Position
            var lessonCells: IdentifiedArrayOf<LessonCell.State>

            var id: String {
                Section.id(week: position.week, day: position.day)
            }

            var index: Int {
                position.index
            }

            struct Position: Equatable, Identifiable {

                static var count: Int {
                    Lesson.Week.allCases.count * Lesson.Day.allCases.count
                }

                static func index(week: Lesson.Week, day: Lesson.Day) -> Int {
                    (week.rawValue - 1) * 6 + (day.rawValue - 1)
                }

                let week: Lesson.Week
                let day: Lesson.Day

                var id: Int {
                    index
                }

                var index: Int {
                    Position.index(week: week, day: day)
                }
            }
        }

        init() {
            self.lessons = []
            self.sections = [Section](lessons: [])
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
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
                state.sections = [State.Section](lessons: state.lessons)
            }
            if let group = environment.userDefaultsClient.get(for: .group) {
                state.groupName = group.name
            }
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
                // TODO: Fix warning with calling every reducer on lesson cells
                return LessonCell.reducer
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

// MARK: - GroupLessons.State.Section.Position

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

// MARK: - Array + GroupLessons.State.Section

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

}
