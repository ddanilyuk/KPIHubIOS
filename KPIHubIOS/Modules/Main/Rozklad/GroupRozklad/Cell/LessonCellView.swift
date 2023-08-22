//
//  LessonCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct LessonCellView: View {

    @Environment(\.colorScheme) var colorScheme

    let store: StoreOf<LessonCell>
    @ObservedObject private var viewStore: ViewStoreOf<LessonCell>
    
    init(store: StoreOf<LessonCell>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Text(viewStore.lesson.position.description.firstPartStart)
                timeView
                Text(viewStore.lesson.position.description.secondPartEnd)
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
        .background(Color.screenBackground)
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
                .onAppear {
                    print("Next on appear")
                }

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
            Text("\(viewStore.lesson.names.joined(separator: ", "))")
                .font(.system(.callout).bold())
                .lineLimit(2)

            
            if viewStore.showTeachers {
                ForEach(viewStore.lesson.teachers ?? [], id: \.self) { teacher in
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
                            text: viewStore.lesson.locations?.first ?? "-",
                            color: .yellow
                        )
                    }
                    if viewStore.showType {
                        SmallTagView(
                            icon: Image(systemName: "graduationcap"),
                            text: viewStore.lesson.type,
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

struct LessonCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LessonCellView(
                store: Store(
                    initialState: LessonCell.State(
                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0]),
                        mode: .default
                    ),
                    reducer: LessonCell()
                )
            )
            .smallPreview

            LessonCellView(
                store: Store(
                    initialState: LessonCell.State(
                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0]),
                        mode: .current(0.34)
                    ),
                    reducer: LessonCell()
                )
            )
            .smallPreview

            LessonCellView(
                store: Store(
                    initialState: LessonCell.State(
                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0]),
                        mode: .next
                    ),
                    reducer: LessonCell()
                )
            )
            .smallPreview
        }
    }
}
