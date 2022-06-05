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
                    Text("\(viewStore.lesson.position.description.firstPartStart)")

                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.gray)
                        .frame(width: 2, alignment: .center)
                        .frame(minHeight: 20)

                    Text("\(viewStore.lesson.position.description.secondPartEnd)")
                }
                .frame(width: 35)
                .font(.system(.footnote))

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(viewStore.lesson.names.joined(separator: ", "))")
                            .font(.system(.callout).bold())
                            .lineLimit(2)

                        ForEach(viewStore.lesson.teachers ?? [], id: \.self) { teacher in
                            SmallTagView(
                                icon: Image(systemName: "person"),
                                text: teacher.shortName,
                                backgroundColor: Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255),
                                accentColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
                            )
                        }

                        HStack {
                            SmallTagView(
                                icon: Image(systemName: "location"),
                                text: "Online",
                                backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                                accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                            )

                            SmallTagView(
                                icon: Image(systemName: "graduationcap"),
                                text: "Практика",
                                backgroundColor: Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255),
                                accentColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                }
            }
            .onTapGesture {
                viewStore.send(.onTap)
            }
            .padding()
            .background(Color.screenBackground)
        }
    }
}

// MARK: - Preview

struct LessonCellView_Previews: PreviewProvider {
    static var previews: some View {

//        VStack {
//            Spacer()
            LessonCellView(
                store: Store(
                    initialState: LessonCell.State(
                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0])
                    ),
                    reducer: LessonCell.reducer,
                    environment: LessonCell.Environment()
                )
            )
            .previewLayout(.sizeThatFits)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: 375)
//            Spacer()
//        }

    }
}
