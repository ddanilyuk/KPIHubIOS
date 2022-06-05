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
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(viewStore.lesson.names.joined(separator: ", "))")
                        .font(.system(.title).bold())
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                    DateAndTime(
                        lessonPositionDescription: viewStore.lesson.position.description,
                        lessonWeek: viewStore.lesson.week,
                        lessonDay: viewStore.lesson.day
                    )

                    VStack(alignment: .leading, spacing: 0) {
                        sectionTitle("Тип")

                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)

                            HStack {
                                LargeTagView(
                                    icon: Image(systemName: "graduationcap"),
                                    text: "Практика",
                                    backgroundColor: Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255),
                                    accentColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
                                )
                                Spacer()
                            }
                            .padding(16)
                        }
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        sectionTitle("Викладач")

                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)

                            VStack(spacing: 16) {
                                ForEach((viewStore.lesson.teachers ?? []), id: \.self) { teacher in
                                    VStack(spacing: 16) {
                                        HStack {
                                            LargeTagView(
                                                icon: Image(systemName: "person"),
                                                text: teacher.shortName,
                                                backgroundColor: Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255),
                                                accentColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
                                            )
                                            Spacer()
                                        }
                                        if teacher != (viewStore.lesson.teachers ?? []).last {
                                            Divider()
                                        }
                                    }
                                }
                            }

                            .padding(16)
                        }
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        sectionTitle("Локація")

                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)

                            VStack(spacing: 10) {
                                HStack {
                                    LargeTagView(
                                        icon: Image(systemName: "location"),
                                        text: "Online",
                                        backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                                        accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                                    )
                                    Spacer()
                                }
                                .padding(.top, 16)
                                .padding(.horizontal, 16)

                                RoundedRectangle(cornerRadius: 0.5)
                                    .fill(Color(.separator))
                                    .frame(height: 1)
                                    .padding(.horizontal, 8)

                                VStack {
                                    HStack(spacing: 16) {
                                        Circle()
                                            .fill(Color.orange.opacity(0.2))
                                            .frame(width: 24, height: 24)
                                        Text("bbb.com")
                                        Spacer()
                                    }
                                    .padding(.vertical, 9)

                                    RoundedRectangle(cornerRadius: 0.5)
                                        .fill(Color(.separator).opacity(0.5))
                                        .frame(height: 1)

                                    HStack(spacing: 16) {
                                        Circle()
                                            .fill(Color.orange.opacity(0.2))
                                            .frame(width: 24, height: 24)
                                        Text("zoom.com")
                                        Spacer()

                                    }
                                    .padding(.vertical, 9)
                                }
                                .padding(.bottom, 8)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(Color.screenBackground)
        .navigationTitle("Деталі")
        .navigationBarTitleDisplayMode(.inline)
    }

    func sectionTitle(_ title: String) -> some View {
        Text("\(title)")
            .font(.system(.subheadline).weight(.regular))
            .padding(.horizontal, 16)
            .frame(height: 25)
    }
}

struct DateAndTime: View {

    enum Constants {
        static let lineHeight: CGFloat = 4
        static var lineCornerRadius: CGFloat {
            return Constants.lineHeight / 2
        }
    }

    let lessonPositionDescription: Lesson.Position.Description
    let lessonWeek: Lesson.Week
    let lessonDay: Lesson.Day

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Дата та час")
                .font(.system(.subheadline).weight(.regular))
                .padding(.horizontal, 16)
                .frame(height: 25)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)

                VStack(spacing: 16) {

                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: Constants.lineCornerRadius)
                            .fill(Color.orange.opacity(0.2))
                            .frame(height: Constants.lineHeight)

                        HStack(spacing: 16) {
                            VStack(spacing: 5) {
                                HStack(alignment: .bottom) {
                                    Text("\(lessonPositionDescription.firstPartStart)")
                                        .font(.footnote.bold())
                                    Spacer()
                                    Text("\(lessonPositionDescription.firstPartEnd)")
                                        .font(.caption2)
                                }
                                .frame(height: 12)

                                RoundedRectangle(cornerRadius: Constants.lineCornerRadius)
                                    .fill(Color.orange)
                                    .frame(height: Constants.lineHeight)

                                Spacer(minLength: 12)
                            }

                            VStack(spacing: 5) {
                                Spacer(minLength: 12)

                                RoundedRectangle(cornerRadius: Constants.lineCornerRadius)
                                    .fill(Color.orange)
                                    .frame(height: Constants.lineHeight)

                                HStack(alignment: .top) {
                                    Text("\(lessonPositionDescription.secondPartStart)")
                                        .font(.caption2)
                                    Spacer()
                                    Text("\(lessonPositionDescription.secondPartEnd)")
                                        .font(.footnote.bold())
                                }
                                .frame(height: 12)

                            }
                        }
                    }

                    HStack {
                        Text("\(lessonDay.fullDescription)")

                        Spacer()

                        Text("\(lessonWeek.description)")
                    }
                    .font(.system(.subheadline).weight(.regular))

                }
                .padding(16)
            }
        }
    }

}

// MARK: - Preview

struct LessonDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LessonDetailsView(
                store: Store(
                    initialState: LessonDetails.State(
                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0])
                    ),
                    reducer: LessonDetails.reducer,
                    environment: LessonDetails.Environment(
                        userDefaultsClient: .live()
                    )
                )
            )
        }
    }
}
