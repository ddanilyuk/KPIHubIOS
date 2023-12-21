//
//  KPIHubIOSIntegrationTests.swift
//  KPIHubIOSIntegrationTests
//
//  Created by Denys Danyliuk on 21.12.2023.
//

import XCTest
import ComposableArchitecture
import RozkladModels
import GeneralServices
import LessonDetailsFeature
@testable import KPIHubIOS

@MainActor
final class KPIHubIOSIntegrationTests: XCTestCase {
    func testRozkladFlow() async throws {
        let lesson = RozkladLessonModel.mock
        let store = TestStore(
            initialState: RozkladFlow.State()
        ) {
            RozkladFlow()
        } withDependencies: {
            $0.currentDateService = .none()
            $0.rozkladServiceState.currentState = {
                .selected(GroupResponse.mock)
            }
            $0.analyticsService = .none()
        }
        store.exhaustivity = .off(showSkippedAssertions: true)
        
        await store.send(.onSetup)
        await store.send(.rozkladRoot(.groupRozklad(.output(.openLessonDetails(lesson)))))
        await store.send(.path(.element(id: 0, action: .lessonDetails(.view(.startEditingButtonTapped)))))
        await store.send(.path(.element(id: 0, action: .lessonDetails(.view(.editNamesButtonTapped))))) {
            $0.path[id: 0, case: \.lessonDetails]?.destination = .editLessonNames(EditLessonNamesFeature.State(lesson: lesson))
        }
        await store.send(.path(.element(
            id: 0, action: .lessonDetails(.destination(.presented(.editLessonNames(.view(.cancelButtonTapped)))))
        )))
        await store.receive(\.path[id: 0].lessonDetails.destination.dismiss)
        await store.send(.path(.popFrom(id: 0)))
        await store.finish()
    }
}
