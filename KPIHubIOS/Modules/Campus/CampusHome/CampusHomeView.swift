//
//  CampusHomeView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import SwiftUI

struct CampusHomeView: View {

    let store: Store<CampusHome.State, CampusHome.Action>

    let accentColor = Color(red: 250 / 255, green: 160 / 255, blue: 90 / 255)
    let backgroundColor = Color(red: 254 / 255, green: 244 / 255, blue: 235 / 255)

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(backgroundColor)
                            .shadow(color: Color(red: 237 / 255, green: 107 / 255, blue: 7 / 255).opacity(0.15), radius: 12, x: 0, y: 6)

                        VStack {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(accentColor)

                                    Image(systemName: "graduationcap")
                                        .font(.system(.body).bold())
                                        .foregroundColor(.white)
                                }
                                .frame(width: 40, height: 40)

                                Text("Поточний контроль")
                                    .font(.system(.body).bold())

                                Spacer()
                            }
                        }
                        .padding(16)
                    }
                }
                .padding(24)
            }
            .background(Color.screenBackground)
            .navigationTitle("Кампус")
        }
    }

}


extension Color {
    static var screenBackground: Color {
        return Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255)
    }
}

// MARK: - Preview

struct CampusHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampusHomeView(
                store: Store(
                    initialState: CampusHome.State(
//                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0])
                    ),
                    reducer: CampusHome.reducer,
                    environment: CampusHome.Environment(
//                        userDefaultsClient: .live()
                    )
                )
            )
        }
    }
}
