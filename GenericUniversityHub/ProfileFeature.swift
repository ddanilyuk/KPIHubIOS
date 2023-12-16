//
//  ProfileFeature.swift
//  GenericUniversityHub
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import ComposableArchitecture

@Reducer
struct ProfileFeature: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable { }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

import SwiftUI

struct ProfileView: View {
    let store: StoreOf<ProfileFeature>
    
    var body: some View {
        Color.pink.opacity(0.5)
    }
}
