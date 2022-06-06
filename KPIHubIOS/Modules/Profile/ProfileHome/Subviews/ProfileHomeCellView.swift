//
//  ProfileHomeCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct ProfileHomeViewCell: View {

    let title: String
    let value: Value
    let imageName: String
    let backgroundColor: Color
    let accentColor: Color

    enum Value {
        case text(String)
        case date(Date)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor)

                Image(systemName: imageName)
                    .foregroundColor(backgroundColor)
                    .font(.system(.body))
            }
            .frame(width: 35, height: 35)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(.caption))
                    .foregroundColor(Color.secondary)

                switch value {
                case let .text(string):
                    Text(string)
                        .font(.system(.body))
                case let .date(date):
                    Text(date, format: .dateTime)
                        .font(.system(.body))
                }
            }

            Spacer()
        }
    }


}
