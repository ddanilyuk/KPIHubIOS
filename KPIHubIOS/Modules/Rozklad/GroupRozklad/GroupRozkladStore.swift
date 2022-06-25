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

        var currentDay: Lesson.Day?
        var currentWeek: Lesson.Week = .first
        var currentLessonId: CurrentLesson?
        var nextLessonId: Lesson.ID?

        var groupName: String = ""
        var lessons: IdentifiedArrayOf<Lesson> = []
        var sections: [Section] = []
        var alreadyAppeared: Bool = false
        var scrollTo: Lesson.ID?

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

        case updateCurrentDate

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
        let userDefaultsClient: UserDefaultsClientable
        let rozkladClient: RozkladClient
        let currentDateClient: CurrentDateClient
    }

    // MARK: - Reducer

    static let coreReducer = Reducer<State, Action, Environment> { state, action, environment in

        enum SubscriberCancelId { }
        switch action {
        case .onAppear:
            state.groupName = environment.userDefaultsClient.get(for: .groupResponse)?.name ?? "ІВ-82"
//            if !state.alreadyAppeared {
//                state.scrollTo = State.Section.id(week: .first, day: .init(rawValue: state.currentDay) ?? .monday)
//                //                state.alreadyAppeared = true
//            }
            return Effect.concatenate(
                Effect(value: .updateCurrentDate),
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
                    environment.currentDateClient.updated
                        .dropFirst()
                        .receive(on: DispatchQueue.main)
                        .sink { _ in
                            subscriber.send(.updateCurrentDate)
                        }
                }
                    .cancellable(id: SubscriberCancelId.self, cancelInFlight: true)

            )

        case .updateCurrentDate:
            state.currentDay = environment.currentDateClient.currentDay.value
            state.currentWeek = environment.currentDateClient.currentWeek.value
            state.currentLessonId = environment.currentDateClient.currentLessonId.value
            state.nextLessonId = environment.currentDateClient.nextLessonId.value
            state.sections = [State.Section](
                lessons: state.lessons,
                currentLesson: state.currentLessonId,
                nextLesson: state.nextLessonId
            )
            return .none

        case let .updateLessons(lessons):
            print("Updating lessons: \(lessons.count)")
            state.lessons = lessons
            state.sections = [State.Section](
                lessons: state.lessons,
                currentLesson: state.currentLessonId,
                nextLesson: state.nextLessonId
            )
            if state.alreadyAppeared {
                return .none
            } else {
                state.alreadyAppeared = true
                return Effect(value: .todaySelected)
                    .delay(for: 0.2, scheduler: DispatchQueue.main)
                    .eraseToEffect()
            }

        case .todaySelected:
            let scrollTo = state.currentLessonId?.lessonId ?? state.nextLessonId
            state.scrollTo = scrollTo
            return .none

        case .resetScrollTo:
            state.scrollTo = nil
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

    init(
        lessons: IdentifiedArrayOf<Lesson>,
        currentLesson: CurrentLesson? = nil,
        nextLesson: Lesson.ID? = nil
    ) {
        let emptyScheduleDays = Array.combine(Lesson.Week.allCases, Lesson.Day.allCases)
            .map {
                GroupRozklad.State.Section(
                    position: .init(week: $0, day: $1),
                    lessonCells: []
                )
            }
        self = lessons.reduce(into: emptyScheduleDays) { partialResult, lesson in
            var mode: LessonMode = .default
            if lesson.id == currentLesson?.lessonId {
                mode = .current(currentLesson?.percent ?? 0)
            } else if lesson.id == nextLesson {
                mode = .next
            }
            let lessonState = LessonCell.State(
                lesson: lesson,
                mode: mode
            )
            partialResult[
                ScheduleDay.index(
                    week: lesson.week,
                    day: lesson.day
                )
            ].lessonCells.append(lessonState)
        }
    }

}
