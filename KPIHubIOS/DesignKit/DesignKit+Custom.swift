//
//  DesignKit+Custom.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 20.12.2023.
//

import SwiftUI
import DesignKit

extension DesignKit {
    static let custom = DesignKit(
        primaryColor: .orange,
        backgroundColor: .orange.opacity(0.2),
        currentLessonColor: .pink,
        nextLessonColor: .green,
        logoImage: Image(.kpiHubLogo)
    )
}
