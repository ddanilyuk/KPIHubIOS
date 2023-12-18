//
//  RozkladLessonModel.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import Services

public struct RozkladLessonModel: Identifiable, Equatable {
    public let id: Int
    public var names: [String]
    public var teachers: [String]?
    public var locations: [String]?
    public var type: String
    public var day: Int
    public var week: Int
    public var position: Position

    public init(lesson: Lesson) {
        self.id = lesson.id
        self.names = lesson.names
        self.teachers = lesson.teachers
        self.locations = lesson.locations
        self.type = lesson.type
        self.day = lesson.day.rawValue
        self.week = lesson.week.rawValue
        self.position = Position(index: lesson.position.rawValue) ?? .first
    }
}

//enum RozkladLessonWeek {
//    case first
//    case second
//}

//extension RozkladLessonModel: Decodable {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int.self, forKey: .id)
//        self.names = try container.decode([String].self, forKey: .names)
//        self.teachers = try container.decodeIfPresent([String].self, forKey: .teachers)
//        self.locations = try container.decode([String].self, forKey: .locations)
//        self.id = try container.decode(Int.self, forKey: .id)
//        self.id = try container.decode(Int.self, forKey: .id)
//        self.id = try container.decode(Int.self, forKey: .id)
//    }
//}

extension RozkladLessonModel {
    public struct Time: Equatable, Codable {
        public let hours: Int
        public let minutes: Int
        
        public init(hours: Int, minutes: Int) {
            self.hours = hours
            self.minutes = minutes
        }
        
        public var minutesFromDayStart: Int {
            hours * 60 + minutes
        }
        
        public var description: String {
            "\(hours):\(String(format: "%02d", minutes))"
        }
    }
    
    public struct Position: Equatable, Codable {
        public let start: Time
        public let breakStart: Time?
        public let breakEnd: Time?
        public let end: Time
        
        public var range: Range<Int> {
            start.minutesFromDayStart..<end.minutesFromDayStart
        }
        
        public init?(index: Int) {
            switch index {
            case 1:
                self = Self.first
                
            case 2:
                self = Self.second
                
            case 3:
                self = Self.third
                
            case 4:
                self = Self.fourth
                
            case 5:
                self = Self.fifth
                
            case 6:
                self = Self.sixth
                
            default:
                return nil
            }
        }
        
        public init(start: Time, breakStart: Time, breakEnd: Time, end: Time) {
            self.start = start
            self.breakStart = breakStart
            self.breakEnd = breakEnd
            self.end = end
        }
    }
}

extension RozkladLessonModel: Codable { }

public enum RozkladLessonMode: Equatable {
    case current(Double)
    case next
    case `default`
    
    public var isCurrent: Bool {
        switch self {
        case .current:
            return true

        case .next, .default:
            return false
        }
    }
    
    public var percent: Double {
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

public struct LessonDay: Equatable, Hashable {
    public let day: Int
    public let week: Int
    
    public var debugDescription: String {
        "Week: \(week) | Day: \(day)"
    }
    
    public init(day: Int, week: Int) {
        self.day = day
        self.week = week
    }
}

/// KPI default values. Can be provided from backend if needed.
extension RozkladLessonModel.Position {
    static var first: Self {
        RozkladLessonModel.Position(
            start: RozkladLessonModel.Time(hours: 8, minutes: 30),
            breakStart: RozkladLessonModel.Time(hours: 9, minutes: 15),
            breakEnd: RozkladLessonModel.Time(hours: 9, minutes: 20),
            end: RozkladLessonModel.Time(hours: 10, minutes: 5)
        )
    }
    
    static var second: Self {
        RozkladLessonModel.Position(
            start: RozkladLessonModel.Time(hours: 10, minutes: 25),
            breakStart: RozkladLessonModel.Time(hours: 11, minutes: 10),
            breakEnd: RozkladLessonModel.Time(hours: 11, minutes: 15),
            end: RozkladLessonModel.Time(hours: 12, minutes: 0)
        )
    }

    static var third: Self {
        RozkladLessonModel.Position(
            start: RozkladLessonModel.Time(hours: 12, minutes: 20),
            breakStart: RozkladLessonModel.Time(hours: 13, minutes: 05),
            breakEnd: RozkladLessonModel.Time(hours: 13, minutes: 10),
            end: RozkladLessonModel.Time(hours: 13, minutes: 55)
        )
    }
    
    static var fourth: Self {
        RozkladLessonModel.Position(
            start: RozkladLessonModel.Time(hours: 14, minutes: 15),
            breakStart: RozkladLessonModel.Time(hours: 15, minutes: 0),
            breakEnd: RozkladLessonModel.Time(hours: 15, minutes: 5),
            end: RozkladLessonModel.Time(hours: 15, minutes: 50)
        )
    }
    
    static var fifth: Self {
        RozkladLessonModel.Position(
            start: RozkladLessonModel.Time(hours: 16, minutes: 10),
            breakStart: RozkladLessonModel.Time(hours: 16, minutes: 55),
            breakEnd: RozkladLessonModel.Time(hours: 17, minutes: 0),
            end: RozkladLessonModel.Time(hours: 17, minutes: 45)
        )
    }
    
    static var sixth: Self {
        RozkladLessonModel.Position(
            start: RozkladLessonModel.Time(hours: 18, minutes: 5),
            breakStart: RozkladLessonModel.Time(hours: 18, minutes: 50),
            breakEnd: RozkladLessonModel.Time(hours: 18, minutes: 55),
            end: RozkladLessonModel.Time(hours: 19, minutes: 40)
        )
    }
}
