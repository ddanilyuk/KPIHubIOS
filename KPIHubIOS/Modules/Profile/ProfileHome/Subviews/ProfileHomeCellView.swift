//
//  ProfileHomeCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct ProfileSection<Content: View>: View {

    let title: String
    let content: Content

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.system(.body).bold())

                content
            }
            .padding()
        }
    }
}

struct ProfileHomeViewCell<ImageContent, ButtonContent>: View where ButtonContent: View, ImageContent: View {

    let title: String
    let value: Value
    let imageName: ImageContent
    let backgroundColor: Color

    var rightView: ButtonContent?

    init(
        title: String,
        value: ProfileHomeViewCell<ImageContent, ButtonContent>.Value,
        @ViewBuilder image: () -> ImageContent,
        backgroundColor: Color,
        @ViewBuilder rightView: () -> ButtonContent
    ) {
        self.title = title
        self.value = value
        self.imageName = image()
        self.backgroundColor = backgroundColor
        self.rightView = rightView()
    }

    init(
        title: String,
        value: ProfileHomeViewCell<ImageContent, ButtonContent>.Value,
        @ViewBuilder image: () -> ImageContent,
        backgroundColor: Color
    ) where ButtonContent == EmptyView {
        self.title = title
        self.value = value
        self.imageName = image()
        self.backgroundColor = backgroundColor
    }

    enum Value {
        case text(String)
        case date(Date?)
        case link(name: String, url: URL)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(backgroundColor)

                imageName
                    .font(.system(.body))
            }
            .frame(width: 35, height: 35)

            VStack(alignment: .leading) {
                if !title.isEmpty {
                    Text(title)
                        .font(.system(.caption))
                        .foregroundColor(Color.secondary)
                }

                switch value {
                case let .text(string):
                    Text(string)
                        .font(.system(.body))

                case let .date(.some(date)):
                    Text(date, format: .dateTime.day().month().year().minute().hour())
                        .font(.system(.body))

                case .date(.none):
                    Text("-")
                        .font(.system(.body))

                case let .link(name, url):
                    Link(name, destination: url)
                }
            }

            Spacer()

            rightView
        }
    }

}
