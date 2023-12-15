//
//  LessonCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import SwiftUI
import ComposableArchitecture
import Services // TODO: ?

struct LessonCellView: View {
    struct ViewState: Equatable {
        let mode: LessonMode
        let lessonType: String
        let lessonNames: [String]
        let teacherNames: [String]?
        let locationNames: [String]?
        let lessonPositionFirstPart: String
        let lessonPositionSecondPart: String
        let showTeachers: Bool
        let showLocationsAndType: Bool
        let showLocations: Bool
        let showType: Bool
        
        init(state: LessonCell.State) {
            let lesson = state.lesson
            let lessonPositionDescription = state.lesson.position.description
            mode = state.mode
            lessonType = lesson.type
            lessonNames = lesson.names
            teacherNames = lesson.teachers
            locationNames = lesson.locations
            lessonPositionFirstPart = lessonPositionDescription.firstPartStart
            lessonPositionSecondPart = lessonPositionDescription.secondPartEnd
            showTeachers = !lesson.isTeachersEmpty
            showLocationsAndType = !lesson.isTypeEmpty || !lesson.isLocationsEmpty
            showLocations = !lesson.isLocationsEmpty
            showType = !lesson.isTypeEmpty
        }
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewStore: ViewStore<ViewState, LessonCell.Action>
    
    init(store: StoreOf<LessonCell>) {
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Text(viewStore.lessonPositionFirstPart)
                timeView
                Text(viewStore.lessonPositionSecondPart)
            }
            .frame(width: 35)
            .font(.system(.footnote))

            ZStack(alignment: .leading) {
                backgroundView
                contentView
            }
        }
        .onTapGesture {
            viewStore.send(.onTap)
        }
        .padding()
        // TODO: assets
//        .background(Color.screenBackground)
    }

    var timeView: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray.opacity(0.2))
                .if(viewStore.mode.isCurrent) { view in
                    view.overlay(alignment: .top) {
                        LinearGradientAnimatableView()
                            .frame(height: viewStore.mode.percent * proxy.frame(in: .local).height)
                    }
                }
        }
        .frame(width: viewStore.mode.isCurrent ? 4 : 2, alignment: .center)
        .frame(minHeight: 20)
    }

    @ViewBuilder
    var backgroundView: some View {
        switch viewStore.mode {
        case .current:
            BorderGradientBackgroundView()
                .overlay(alignment: .topTrailing) {
                    BadgeView(mode: viewStore.mode)
                }

        case .next:
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
                .overlay(alignment: .topTrailing) {
                    BadgeView(mode: .next)
                }
                .shadow(color: Color.blue.opacity(colorScheme == .light ? 0.2 : 0.5), radius: 8, x: 0, y: 4)

        case .default:
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
            Text("\(viewStore.lessonNames.joined(separator: ", "))")
                .font(.system(.callout).bold())
                .lineLimit(2)
            
            if viewStore.showTeachers {
                ForEach(viewStore.teacherNames ?? [], id: \.self) { teacher in
                    SmallTagView(
                        icon: Image(systemName: "person"),
                        text: teacher,
                        color: .indigo
                    )
                }
            }
            
            if viewStore.showLocationsAndType {
                HStack {
                    if viewStore.showLocations {
                        SmallTagView(
                            icon: Image(systemName: "location"),
                            text: viewStore.locationNames?.first ?? "-",
                            color: .yellow
                        )
                    }
                    if viewStore.showType {
                        SmallTagView(
                            icon: Image(systemName: "graduationcap"),
                            text: viewStore.lessonType,
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

// MARK: - Preview
#Preview {
    LessonCellView(
        store: Store(
            initialState: LessonCell.State(
                lesson: Lesson(lessonResponse: LessonResponse.mocked[0]),
                mode: .default
            )
        ) {
            LessonCell()
        }
    )
    .smallPreview
}

#Preview {
    LessonCellView(
        store: Store(
            initialState: LessonCell.State(
                lesson: Lesson(lessonResponse: LessonResponse.mocked[0]),
                mode: .current(0.34)
            )
        ) {
            LessonCell()
        }
    )
    .smallPreview
}

#Preview {
    LessonCellView(
        store: Store(
            initialState: LessonCell.State(
                lesson: Lesson(lessonResponse: LessonResponse.mocked[0]),
                mode: .next
            )
        ) {
            LessonCell()
        }
    )
    .smallPreview
}
