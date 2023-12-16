//
//  DesignKit.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import SwiftUI

public struct DesignKit {
    public let primaryColor: Color
    public let backgroundColor: Color
    
    public let currentLessonColor: Color
    public let nextLessonColor: Color

    
    public init(
        primaryColor: Color,
        backgroundColor: Color,
        currentLessonColor: Color,
        nextLessonColor: Color
    ) {
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.currentLessonColor = currentLessonColor
        self.nextLessonColor = nextLessonColor
    }
}


extension EnvironmentValues {
    private struct DesignKitEnvironmentKey: EnvironmentKey {
        static let defaultValue = DesignKit(
            primaryColor: .orange,
            backgroundColor: .white,
            currentLessonColor: .orange,
            nextLessonColor: .blue
        )
    }
    
    public var designKit: DesignKit {
        get { self[DesignKitEnvironmentKey.self] }
        set { self[DesignKitEnvironmentKey.self] = newValue }
    }
}
