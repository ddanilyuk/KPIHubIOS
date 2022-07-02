//
//  LessonCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct LessonCellView: View {

    let store: Store<LessonCell.State, LessonCell.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
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
    }

    var timeView: some View {
        WithViewStore(store) { viewStore in
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
    }

    var backgroundView: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.mode {
            case .current:
                BorderGradientBackgroundView()
                    .overlay(alignment: .topTrailing) {
                        BadgeView(mode: viewStore.mode)
                    }

            case .next:
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(alignment: .topTrailing) {
                        BadgeView(mode: .next)
                    }
                    .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)

            case .default:
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
        }
    }

    var contentView: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 10) {
                Text("\(viewStore.lesson.names.joined(separator: ", "))")
                    .font(.system(.callout).bold())
                    .lineLimit(2)


                ForEach(viewStore.lesson.teachers ?? [], id: \.self) { teacher in
                    SmallTagView(
                        icon: Image(systemName: "person"),
                        text: teacher,
                        backgroundColor: Color.indigo.lighter(by: 0.9),
                        accentColor: Color.indigo
                    )
                }

                HStack {
                    SmallTagView(
                        icon: Image(systemName: "location"),
                        text: viewStore.lesson.locations?.first ?? "-",
                        backgroundColor: Color.yellow.lighter(by: 0.9),
                        accentColor: Color.yellow
                    )

                    SmallTagView(
                        icon: Image(systemName: "graduationcap"),
                        text: viewStore.lesson.type,
                        backgroundColor: Color.cyan.lighter(by: 0.9),
                        accentColor: Color.cyan
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
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
                    reducer: LessonCell.reducer,
                    environment: LessonCell.Environment()
                )
            )
            .smallPreview

            LessonCellView(
                store: Store(
                    initialState: LessonCell.State(
                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0]),
                        mode: .current(0.34)
                    ),
                    reducer: LessonCell.reducer,
                    environment: LessonCell.Environment()
                )
            )
            .smallPreview

            LessonCellView(
                store: Store(
                    initialState: LessonCell.State(
                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0]),
                        mode: .next
                    ),
                    reducer: LessonCell.reducer,
                    environment: LessonCell.Environment()
                )
            )
            .smallPreview
        }
    }
}
