//
//  GroupLessonsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct GroupLessonsView: View {

    let store: Store<GroupLessons.State, GroupLessons.Action>

    var body: some View {
        Text("GroupLessons")
            .navigationTitle("ІВ-82")
    }

}
