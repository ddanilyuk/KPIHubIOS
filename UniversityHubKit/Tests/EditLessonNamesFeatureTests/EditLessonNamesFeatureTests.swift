//
//  EditLessonNamesFeatureTests.swift
//  
//
//  Created by Denys Danyliuk on 21.12.2023.
//

import Foundation
import XCTest
import ComposableArchitecture
@testable import RozkladModels
@testable import EditLessonNamesFeature
@testable import GeneralServices

@MainActor
class EditLessonNamesFeatureTests: XCTestCase {
    func testEditFlow() async throws {
        var actualEvents: [Event] = []
        var expectedEvents: [Event] = []
        let lesson = RozkladLessonModel.mock
        let dismissed = LockIsolated(false)
        
        let store = TestStore(
            initialState: EditLessonNamesFeature.State(
                lesson: lesson
            )
        ) {
            EditLessonNamesFeature()
        } withDependencies: {
            $0.analyticsService.track = { event in
                actualEvents.append(event)
            }
            $0.dismiss = .init { dismissed.setValue(true) }
        }
        await store.send(.view(.onAppear))
        expectedEvents.append(Event.LessonDetails.editNamesAppeared)
        XCTAssertNoDifference(actualEvents, expectedEvents)
        
        var selectedNames = lesson.names
        let unselectedLesson = selectedNames.remove(at: 1)
        await store.send(.view(.toggleLessonNameTapped(name: lesson.names[1]))) { state in
            state.selected = selectedNames
        }
        
        selectedNames.append(unselectedLesson)
        await store.send(.view(.toggleLessonNameTapped(name: lesson.names[1]))) { state in
            state.selected = selectedNames
        }
        
        selectedNames.removeAll(where: { $0 == lesson.names[1] })
        await store.send(.view(.toggleLessonNameTapped(name: lesson.names[1]))) { state in
            state.selected = selectedNames
        }
        
        await store.send(.view(.cancelButtonTapped))
        
        XCTAssert(dismissed.value)
    }
}
