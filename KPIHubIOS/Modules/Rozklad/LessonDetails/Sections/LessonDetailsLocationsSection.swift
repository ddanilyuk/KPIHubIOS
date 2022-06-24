//
//  LessonDetailsLocationsSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct LessonDetailsLocationsSection: View {

    var locations: [String]

    var body: some View {
        LessonDetailsSectionView(
            title: "Локація",
            content: { content }
        )
    }

    var content: some View {
        VStack(spacing: 0) {
            ForEach(locations, id: \.self) { location in
                VStack(spacing: 16) {
                    HStack {
                        LargeTagView(
                            icon: Image(systemName: "location"),
                            text: location,
                            backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                            accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                        )

                        Spacer()
                    }
                    if location != locations.last {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
    }

}

/// Not used for now
private struct LinksView: View {

    var body: some View {
        Divider()
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

            Divider()
                .opacity(0.5)

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
