//
//  GroupRozkladStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import IdentifiedCollections
import ComposableArchitecture
import Foundation

var toggleWeek: Bool = true

struct GroupRozklad {

    // MARK: - State

    struct State: Equatable {

        var currentDay: Int = 1
        var currentWeek: Int = 1
        var groupName: String = ""
        var lessons: IdentifiedArrayOf<Lesson> = []
        var sections: [Section] = []
        var alreadyAppeared: Bool = false
        var scrollTo: String?
        var lessonCells: IdentifiedArrayOf<LessonCell.State> {
            get {
                sections
                    .map { $0.lessonCells }
                    .reduce([], {
                        var partialResult = $0
                        partialResult.append(contentsOf: $1.elements)
                        return partialResult
                    })
            }
            set {
                lessons = IdentifiedArrayOf(uniqueElements: newValue.map { $0.lesson })
                sections = [State.Section](lessons: lessons)
            }
        }

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

        init(groupName: String) {
            self.groupName = groupName
            self.lessons = IdentifiedArrayOf(uniqueElements: LessonResponse.mocked.map { Lesson(lessonResponse: $0) })
            self.sections = [Section](lessons: self.lessons)

        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case updateLessons(IdentifiedArrayOf<Lesson>)
        case updateDate(Date)

        case resetScrollTo
        case todaySelected

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
        let rozkladClient: RozkladClient
    }

    // MARK: - Reducer

    static let coreReducer = Reducer<State, Action, Environment> { state, action, environment in

        enum SubscriberCancelId { }
        switch action {
        case .onAppear:
            state.groupName = environment.userDefaultsClient.get(for: .group)?.name ?? "ІВ-82"
//            if !state.alreadyAppeared {
//                state.scrollTo = State.Section.id(week: .first, day: .init(rawValue: state.currentDay) ?? .monday)
//                //                state.alreadyAppeared = true
//            }
            return Effect.concatenate(
                Effect(value: .updateDate(Date())),
                Effect(value: .updateLessons(environment.rozkladClient.lessons.subject.value)),
                Effect.run { subscriber in
                    environment.rozkladClient.lessons.subject
                        .dropFirst()
                        .receive(on: DispatchQueue.main)
                        .sink { lessons in
                            print("subscriberEvent")
                            subscriber.send(.updateLessons(lessons))
                        }
                }
                .cancellable(id: SubscriberCancelId.self, cancelInFlight: true),
                Effect.run { subscriber in
                    Timer.publish(every: 1, on: .main, in: .default)
                        .autoconnect()
                        .receive(on: DispatchQueue.main)
                        .sink { date in
                            subscriber.send(.updateDate(date))
                        }
                }
                .cancellable(id: SubscriberCancelId.self, cancelInFlight: true)
            )

        case let .updateLessons(lessons):
            print("Updating lessons: \(lessons.count)")
            state.lessons = lessons
            state.sections = [State.Section](lessons: state.lessons)
            if state.alreadyAppeared {
                return .none
            } else {
                state.alreadyAppeared = true
                return Effect(value: .todaySelected)
                    .delay(for: 0.2, scheduler: DispatchQueue.main)
                    .eraseToEffect()
            }

        case .todaySelected:
            state.scrollTo = State.Section.id(
                week: .init(rawValue: state.currentWeek) ?? .first,
                day: .init(rawValue: state.currentDay) ?? .monday
            )
            return .none

        case .resetScrollTo:
            state.scrollTo = nil
            return .none

        case let .updateDate(date):
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.hour, .minute, .weekOfYear, .weekday], from: Date())
            let some = components.weekday
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            var weekOfYear = components.weekOfYear ?? 0
//            let week2 = components.yearForWeekOfYear ?? 0

            var minutesFromStart = hour * 60 + minute
//            print(minutesFromStart)

            var day = components.weekday! - 1
            if day == 0 {
                day = 7
            }
            state.currentDay = day
            if toggleWeek {
                weekOfYear += 1
            }
            state.currentWeek = weekOfYear % 2 + 1
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
        LessonCell.reducer
            .forEach(
                state: \State.lessonCells,
                action: /Action.lessonCells,
                environment: { _ in LessonCell.Environment() }
            ),
        coreReducer
    )

}

// MARK: - GroupRozklad.State.Section.Position

extension GroupRozklad.State.Section.Position {

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

// MARK: - Array + GroupRozklad.State.Section

extension Array where Element == GroupRozklad.State.Section {

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
                GroupRozklad.State.Section(
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
