//
//  LessonDetailsTitleView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

public struct LessonDetailsTitleView: View {
    var title: String
    var isEditing: Bool
    
    public init(title: String, isEditing: Bool) {
        self.title = title
        self.isEditing = isEditing
    }

    public var body: some View {
        HStack {
            if isEditing {
                EditingView()
            }
            Text(title)
                .font(.system(.title).bold())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }
}
