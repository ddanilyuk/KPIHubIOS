//
//  RozkladView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import SwiftUI
import DesignKit
import ComposableArchitecture
import RozkladFeature

@ViewAction(for: RozkladFeature.self)
struct RozkladView: View {
    @Bindable var store: StoreOf<RozkladFeature>
//    public var cell: (StoreOf<RozkladLessonFeature>) -> Cell
    
    @Environment(\.designKit) private var designKit
    
    var body: some View {
        VStack {
            Text("store.lessonDay day: \(store.lessonDay?.day ?? 0) week: \(store.lessonDay?.week ?? 0)")
            
            ScrollView {
                ForEach(store.scope(state: \.rows, action: \.view.rows)) { childStore in
                    VStack {
                        RozkladRowProviderView(store: childStore) { cellStore in
                            RozkladLessonView(store: cellStore)
                        }
                        .id(childStore.withState { $0.lessonDay })
                    }
                    .scrollTargetLayout()
                }
            }
            .scrollPosition(id: $store.lessonDay, anchor: .top)
            .background(designKit.backgroundColor)
        }
        .navigationTitle("Розклад")
    }
}
