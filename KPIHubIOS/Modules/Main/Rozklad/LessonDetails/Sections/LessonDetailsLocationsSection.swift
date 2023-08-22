//
//  LessonDetailsLocationsSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct LessonDetailsLocationsSection: View {

    @Environment(\.colorScheme) var colorScheme

    var locations: [String]

    var body: some View {
        LessonDetailsSectionView(
            title: "Локація",
            content: { content }
        )
    }

    var content: some View {
        VStack(spacing: 16) {
            ForEach(locations, id: \.self) { location in
                VStack(spacing: 16) {
                    HStack(spacing: 0) {
                        LargeTagView(
                            icon: Image(systemName: "location"),
                            text: location,
                            color: .yellow
                        )

                        Spacer()
                    }
                    // If you add a separator, then text wrapping and layout will break
                    // if teacher != teachers.last {
                    //    Divider()
                    // }
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
