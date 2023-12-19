//
//  RozkladTests.swift
//  KPIHubIOSSnapshotTests
//
//  Created by Denys Danyliuk on 19.12.2023.
//

import XCTest
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import RozkladFeature
import RozkladModels
import Services
@testable import KPIHubIOS

class RozkladTests: XCTestCase {
    override func setUp() {
        super.setUp()
//        isRecording = true
    }
    
    func testRozklad() {
        isRecording = true
        let testBundle = Bundle(for: type(of: self))
         
        let store = StoreOf<RozkladFeature>(
            initialState: RozkladFeature.State(),
            reducer: {
                RozkladFeature()
            },
            withDependencies: {
                $0.analyticsService = .none()
                
                let json = loadFromBundle(
                    testBundle: testBundle,
                    filename: "GroupRozklad",
                    as: LessonsResponse.self
                )
                let legacyLessons = json.lessons.map(Lesson.init)
                let lessons = legacyLessons.map { RozkladLessonModel(lesson: $0) }
                print("!!! LESESE: \(lessons)")
                $0.rozkladServiceLessons.currentLessons = {
                    IdentifiedArray(uniqueElements: lessons )
                }
                
                $0.currentDateService.currentDay = { 1 }
                $0.currentDateService.currentWeek = { 1 }
                $0.currentDateService.currentLesson = { .init(lessonID: lessons[0].id, percent: 0.24) }
                $0.currentDateService.nextLessonID = { lessons[1].id }
            }
        )
        
        assertAllSnapshots {
            NavigationStack {
                RozkladView(store: store)
                    .background(Color.gray.opacity(0.2))
            }
            .environment(\.designKit, .custom)
        }
    }
}


func loadFromBundle<T: Decodable>(testBundle: Bundle, filename: String, as type: T.Type) -> T {
    let data: Data
    
    guard let file = testBundle.url(forResource: filename, withExtension: "json")
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
