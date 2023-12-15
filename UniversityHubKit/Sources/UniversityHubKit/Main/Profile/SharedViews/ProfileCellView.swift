//
//  ProfileCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct ProfileCellView<ImageContent: View, ButtonContent: View>: View {
    enum Value {
        case text(String)
        case date(Date?)
        case link(name: String, url: URL)
    }

    let title: String
    let value: Value
    let imageView: ImageContent
    let imageBackgroundColor: Color

    var rightView: ButtonContent?

    init(
        title: String,
        value: ProfileCellView<ImageContent, ButtonContent>.Value,
        @ViewBuilder image: () -> ImageContent,
        imageBackgroundColor: Color,
        @ViewBuilder rightView: () -> ButtonContent
    ) {
        self.title = title
        self.value = value
        self.imageView = image()
        self.imageBackgroundColor = imageBackgroundColor
        self.rightView = rightView()
    }

    init(
        title: String,
        value: ProfileCellView<ImageContent, ButtonContent>.Value,
        @ViewBuilder image: () -> ImageContent,
        imageBackgroundColor: Color
    ) where ButtonContent == EmptyView {
        self.title = title
        self.value = value
        self.imageView = image()
        self.imageBackgroundColor = imageBackgroundColor
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(imageBackgroundColor)

                imageView
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

        .frame(minHeight: 44)
    }
}
