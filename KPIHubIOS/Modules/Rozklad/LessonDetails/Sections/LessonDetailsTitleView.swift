//
//  LessonDetailsTitleView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct LessonDetailsTitleView: View {

    var title: String
    var isEditing: Bool
    var onTap: () -> Void

    var body: some View {
        HStack {
            if isEditing {
                EditingView()
            }
            Text(title)
                .font(.system(.title).bold())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture {
            onTap()
        }
    }
    
}
