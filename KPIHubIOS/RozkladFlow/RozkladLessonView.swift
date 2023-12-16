//
//  RozkladLessonView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import RozkladFeature
import SwiftUI
import DesignKit
import RozkladModels

@ViewAction(for: RozkladLessonFeature.self)
struct RozkladLessonView: View {
    @Environment(\.colorScheme) var colorScheme
    let store: StoreOf<RozkladLessonFeature>
    
    init(store: StoreOf<RozkladLessonFeature>) {
        self.store = store
    }
    
    var body: some View {
        HStack(spacing: 16) {
//            VStack {
//                Text(viewStore.lessonPositionFirstPart)
//                timeView
//                Text(viewStore.lessonPositionSecondPart)
//            }
            Color.gray.opacity(0.5)
                .frame(width: 35)
                .font(.system(.footnote))

            ZStack(alignment: .leading) {
                backgroundView
                contentView
            }
        }
        .onTapGesture {
            send(.onTap)
        }
        .padding()
        // TODO: assets
//        .background(Color.screenBackground)
    }

//    var timeView: some View {
//        GeometryReader { proxy in
//            RoundedRectangle(cornerRadius: 2)
//                .fill(Color.gray.opacity(0.2))
//                .if(viewStore.mode.isCurrent) { view in
//                    view.overlay(alignment: .top) {
//                        LinearGradientAnimatableView()
//                            .frame(height: viewStore.mode.percent * proxy.frame(in: .local).height)
//                    }
//                }
//        }
//        .frame(width: viewStore.mode.isCurrent ? 4 : 2, alignment: .center)
//        .frame(minHeight: 20)
//    }

    @ViewBuilder
    var backgroundView: some View {
        switch store.status {
        case .current:
            BorderGradientBackgroundView()
                .overlay(alignment: .topTrailing) {
                    LessonBadgeView(mode: .current)
                }

        case .next:
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
                .overlay(alignment: .topTrailing) {
                    LessonBadgeView(mode: .next)
                }
                .shadow(color: Color.blue.opacity(colorScheme == .light ? 0.2 : 0.5), radius: 8, x: 0, y: 4)

        case .idle:
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
                .if(colorScheme == .light) { view in
                    view
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
        }
    }

    var contentView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(store.lesson.names.joined(separator: ", "))")
                .font(.system(.callout).bold())
                .lineLimit(2)
            
            if let teachers = store.lesson.teachers, !teachers.isEmpty {
                ForEach(teachers, id: \.self) { teacher in
                    SmallTagView(
                        icon: Image(systemName: "person"),
                        text: teacher,
                        color: .indigo
                    )
                }
            }
            
            if store.lesson.locations != nil || !store.lesson.type.isEmpty {
                HStack {
                    if let locations = store.lesson.locations {
                        SmallTagView(
                            icon: Image(systemName: "location"),
                            text: locations.first ?? "-",
                            color: .yellow
                        )
                    }
                    if !store.lesson.type.isEmpty {
                        SmallTagView(
                            icon: Image(systemName: "graduationcap"),
                            text: store.lesson.type,
                            color: .cyan
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}

import Services

#Preview {
    let lesson = RozkladLessonModel(lesson: Lesson(lessonResponse: LessonResponse.mocked[0]))
    
    return RozkladLessonView(
        store: Store(initialState: RozkladLessonFeature.State(lesson: lesson, status: .idle)) {
            RozkladLessonFeature()
        }
    )
}
