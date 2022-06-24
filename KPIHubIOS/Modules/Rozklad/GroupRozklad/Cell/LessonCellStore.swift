//
//  LessonCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import ComposableArchitecture
import CoreGraphics

struct LessonCell {

    // MARK: - State

    struct State: Equatable, Identifiable, Hashable {
        let lesson: Lesson
        var mode: Mode = .default

        enum Mode: Equatable {
            case current(CGFloat)
            case next
            case `default`

            var percent: CGFloat {
                switch self {
                case let .current(value):
                    return value
                case .default:
                    return 0
                case .next:
                    return 0
                }
            }
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        var id: Lesson.ID {
            return lesson.id
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onTap
        case onAppear
        case onDisappear
        case updateDate(Date)
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        enum SubscriberCancelId {}
        switch action {
        case .onTap:
            return .none

        case .onAppear:
            return Effect.concatenate(
                Effect(value: .updateDate(Date())),

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

        case .onDisappear:
            return .cancel(id: SubscriberCancelId.self)

        case let .updateDate(date):
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            var minutesFromStart = hour * 60 + minute
            print(minutesFromStart)

            let lessonMinutesFromStart = state.lesson.position.minutesFromDayStart
            if minutesFromStart < lessonMinutesFromStart {
                state.mode = .default
                return .none
            }
            // 08:30 = 510
            // 10:05 = 605

            // 09:00 = 540
//             10:25 =

            // 540 - 510 > 0
//            let diff = minutesFromStart - lessonMinutesFromStart
//            if diff < Lesson.Position.lessonDuration {
//                state.mode = .current(CGFloat(diff) / CGFloat(Lesson.Position.lessonDuration))
//            }
//            if Lesson.Position.lessonDuration +  <

            return .none
        }
    }

}

import Combine
//
//extension Effect {
//
//    static func fireAndSubscribe<T>(
//        _ currentValueSubject: CurrentValueSubject<Output, Never>,
//        transform: @escaping (Output) -> T
//    ) -> Effect<T, Never> {
////        let trans = transform(out)
////        Effect(value: l)
////        Effect(value: .)
//    }
//}
