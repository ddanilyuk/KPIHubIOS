//
//  RozkladView.swift
//  GenericUniversityHub
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import SwiftUI
import DesignKit
import ComposableArchitecture
import RozkladFeature

@ViewAction(for: RozkladFeature.self)
public struct RozkladView<Cell: View>: View {
    public let store: StoreOf<RozkladFeature>
    public var cell: (StoreOf<RozkladLessonFeature>) -> Cell
    
    @Environment(\.designKit) private var designKit
    
    public init(
        store: StoreOf<RozkladFeature>,
        @ViewBuilder cell: @escaping (StoreOf<RozkladLessonFeature>) -> Cell
    ) {
        self.store = store
        self.cell = cell
    }
    
    public var body: some View {
        ScrollView {
            ForEach(store.scope(state: \.rows, action: \.view.rows)) { childStore in
                cell(childStore)
            }
        }
        .background(designKit.backgroundColor)
        .navigationTitle("Розклад")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Circle()
                    .fill(designKit.primaryColor)
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        send(.profileButtonTapped)
                    }
            }
        }
//        .toolbar(.automatic, for: .navigationBar)
    }
}
