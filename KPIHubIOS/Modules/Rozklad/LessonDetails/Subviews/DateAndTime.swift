//
//  DateAndTime.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

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
