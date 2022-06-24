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
                    .if(viewStore.mode.percent != 0) { view in
                        view.overlay(alignment: .top) {
                            GradientAnimationView()
                                .frame(height: viewStore.mode.percent * proxy.frame(in: .local).height)
                        }
                    }
            }
            .frame(width: viewStore.mode.percent == 0 ? 2 : 4, alignment: .center)
            .frame(minHeight: 20)
        }
    }

    var backgroundView: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.mode {
            case .current:
                CurrentLessonBackgroundView()
                    .overlay(alignment: .topTrailing) {
                        BadgeView(mode: viewStore.mode)
                    }
                    .shadow(color: viewStore.mode.shadowColor, radius: 8, x: 0, y: 4)

            case .next:
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(alignment: .topTrailing) {
                        BadgeView(mode: .next)
                    }
                    .shadow(color: viewStore.mode.shadowColor, radius: 8, x: 0, y: 4)

            case .default:
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: viewStore.mode.shadowColor, radius: 8, x: 0, y: 4)
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
                        text: teacher.shortName,
                        backgroundColor: Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255),
                        accentColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
                    )
                }

                HStack {
                    SmallTagView(
                        icon: Image(systemName: "location"),
                        text: viewStore.lesson.locations?.first ?? "-",
                        backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                        accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                    )

                    SmallTagView(
                        icon: Image(systemName: "graduationcap"),
                        text: viewStore.lesson.type,
                        backgroundColor: Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255),
                        accentColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
    }
}

// MARK: - CurrentLessonBackgroundView

private struct CurrentLessonBackgroundView: View {

    @State var gradientAngle: Double = 0

//    let so = LinearGradient(

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                Color.white,
                strokeBorder: AngularGradient(
                    gradient: Gradient(colors: [
                        .red.opacity(0.7),
                        .orange.opacity(0.7),
                        .purple.opacity(0.7),
                        .yellow.opacity(0.7),
                        .red.opacity(0.7)
                    ]),
                    center: .center,
                    angle: .degrees(gradientAngle)
                ),
                lineWidth: 2
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                    self.gradientAngle = 360
                }
            }
    }
}

struct GradientAnimationView: View {
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0

    let startGradient = Gradient(colors: [.purple, .yellow]) // Very popular these days
    let endGradient = Gradient(colors: [.blue, .purple]) // Very popular these days

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .animatableGradient(fromGradient: startGradient, toGradient: endGradient, progress: progress)
            .cornerRadius(2)
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: true)) {
                    self.progress = 1.0
                }
            }
//        LinearGradient(gradient: startGradient,
//                       startPoint: isAnimating ? .bottom : .top,
//                       endPoint: .top)
//        .animation(.linear(duration: 2).repeatForever(autoreverses: true),
//                   value: isAnimating)
//        .onAppear { isAnimating.toggle() }  // light the fuze
    }
}

struct AnimatableGradientModifier: AnimatableModifier {
    let fromGradient: Gradient
    let toGradient: Gradient
    var progress: CGFloat = 0.0

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        var gradientColors = [Color]()

        for index in 0..<fromGradient.stops.count {
            let fromColor = UIColor(fromGradient.stops[index].color)
            let toColor = UIColor(toGradient.stops[index].color)

            gradientColors.append(colorMixer(fromColor: fromColor, toColor: toColor, progress: progress))
        }

        return LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    func colorMixer(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> Color {
        guard let fromColor = fromColor.cgColor.components else {
            return Color(fromColor)
        }
        guard let toColor = toColor.cgColor.components else {
            return Color(toColor)
        }

        let red = fromColor[0] + (toColor[0] - fromColor[0]) * progress
        let green = fromColor[1] + (toColor[1] - fromColor[1]) * progress
        let blue = fromColor[2] + (toColor[2] - fromColor[2]) * progress

        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

extension View {
    func animatableGradient(fromGradient: Gradient, toGradient: Gradient, progress: CGFloat) -> some View {
        self.modifier(AnimatableGradientModifier(fromGradient: fromGradient, toGradient: toGradient, progress: progress))
    }
}

// MARK: - BadgeView

private struct BadgeView: View {

    let mode: LessonCell.State.Mode

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 4, height: 4)
            Text(badgeText(for: mode))
        }
        .font(.system(.footnote).bold())
        .padding(.vertical, 0)
        .padding(.horizontal, 6)
        .foregroundColor(.white)
        .background(
            Rectangle()
                .fill(badgeBackgroundColor(for: mode))
                .cornerRadius(8, corners: [.topRight, .bottomLeft])
        )
    }

    func badgeBackgroundColor(for mode: LessonCell.State.Mode) -> Color {
        switch mode {
        case .current:
            return Color.orange

        case .next:
            return Color.blue

        case .default:
            return Color.clear
        }
    }

    func badgeText(for mode: LessonCell.State.Mode) -> String {
        switch mode {
        case .current:
            return "Зараз"

        case .next:
            return "Далі"

        case .default:
            return ""
        }
    }

}

// MARK: - shadowColor

extension LessonCell.State.Mode {
    var shadowColor: Color {
        switch self {
        case .current:
            return Color.orange.opacity(0.3)

        case .next:
            return Color.blue.opacity(0.2)

        case .default:
            return Color.black.opacity(0.1)
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
