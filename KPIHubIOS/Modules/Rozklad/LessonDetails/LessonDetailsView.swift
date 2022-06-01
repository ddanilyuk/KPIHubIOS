//
//  LessonDetailsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct LessonDetailsView: View {

    let store: Store<LessonDetails.State, LessonDetails.Action>

    var body: some View {
        Text("LessonDetails")
            .navigationTitle("Деталі")
            .navigationBarTitleDisplayMode(.inline)
    }

}
