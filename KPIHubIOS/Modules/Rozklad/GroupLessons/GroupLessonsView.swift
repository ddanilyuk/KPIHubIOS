//
//  GroupLessonsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// We need to set in root of the file because we don't need to recreate it with GroupLessonsView
// and we don't need to body in GroupLessonsView when AnimationViewModel changes.
private var animationModel: AnimationViewModel = .init()

class AnimationViewModel: ObservableObject {

    @Published var position: GroupLessons.State.Section.Position = .init(week: .first, day: .monday)
    var renderedPosition: GroupLessons.State.Section.Position = .init(week: .first, day: .monday)

    var offsets: [CGFloat?] = Array(
        repeating: nil,
        count: GroupLessons.State.Section.Position.count
    )
    var savedOffsets: [CGFloat?] = Array(
        repeating: nil,
        count: GroupLessons.State.Section.Position.count
    )

    func save() {
        savedOffsets = offsets
    }

    func restore() {
        offsets = savedOffsets
        render()
    }

    func setOffset(for index: Int, value: CGFloat?) {
        if offsets[index] == value {
            return
        }
        offsets[index] = value
        render()
    }

    func render() {
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            let newPosition = GroupLessons.State.Section.Position(
                index: min(max(0, calculateIndex()), 11)
            )
            if newPosition != renderedPosition {
                DispatchQueue.main.async { [self] in
                    position = newPosition
                }
            }
            renderedPosition = newPosition
        }
    }

    func debug() {
        let debug = offsets.map { optionalFloat in
            if let float = optionalFloat {
                return "\(float.rounded())"
            } else {
                return "nil"
            }
        }
        .joined(separator: " | ")
        print(debug)
    }

    struct LastShownElement {
        var index: Int
        var value: CGFloat
    }

    var lastShownElement: LastShownElement?

    func calculateIndex() -> Int {
        let target: CGFloat = 169.0 + 1 // 125
        let offsets = offsets
        let numberOfElements = offsets.compactMap { $0 }.count

        func compareWithTarget(element: CGFloat, index: Int) -> Int {
            element < target ? index : index - 1
        }

        switch numberOfElements {
        case 1:
            let index = offsets.firstIndex(where: { $0 != nil })!
            let element = offsets[index]!
            lastShownElement = LastShownElement(index: index, value: element)
            return compareWithTarget(element: element, index: index)

        case 0:
            guard let lastShownElement = lastShownElement else {
                return 0
            }
            return compareWithTarget(element: lastShownElement.value, index: lastShownElement.index)

        default:
            let index = offsets.firstIndex(where: { $0 != nil })!
            let element = offsets[index]!
            if element < target {
                return offsets.lastIndex(where: { $0 != nil ? $0! < target : false }) ?? index
            } else {
                return index - 1
            }
        }
    }

}

struct GroupLessonsView: View {

    @State var selectedWeek: Lesson.Week?
    @State var selectedDay: Lesson.Day?

    @State var displayedWeek: Lesson.Week = .first
    @State var displayedDay: Lesson.Day = .monday

    let store: Store<GroupLessons.State, GroupLessons.Action>

    init(store: Store<GroupLessons.State, GroupLessons.Action>) {
        self.store = store

        UITableView.appearance().sectionHeaderTopPadding = 0
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                HeaderTest(
                    animation: animationModel,
                    groupName: viewStore.groupName,
                    selectedWeek: $selectedWeek,
                    selectedDay: $selectedDay,
                    displayedWeek: $displayedWeek,
                    displayedDay: $displayedDay
                )

                scrollView
            }
            .navigationBarHidden(true)
            .onAppear {
                viewStore.send(.onAppear)
                animationModel.restore()
            }
            .onDisappear {
                animationModel.save()
                print("Screen disappear")
            }
        }
    }

    @State var lastHeaderBottom: CGFloat?
    @State var lastFooterTop: CGFloat?
    @State var lastSection: [CGFloat] = []

    var scrollView: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geometryProxy in
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(viewStore.sections, id: \.id) { section in
                                Section(
                                    content: {
                                        ForEachStore(
                                            self.store.scope(
                                                state: \.sections[section.index].lessonCells,
                                                action: GroupLessons.Action.lessonCells(id:action:)
                                            ),
                                            content: { store in
                                                LessonCellView(store: store)
                                                    .if(section.index == 11, transform: { view in
                                                        view.modifier(
                                                            SizeModifier {
                                                                lastSectionOffsetModifiers(
                                                                    index: ViewStore(store).state.lesson.position.rawValue,
                                                                    height: $0.height
                                                                )
                                                            }
                                                        )
                                                    })
                                            }
                                        )
                                    },
                                    header: {
                                        sectionHeader(
                                            day: section.position.day,
                                            week: section.position.week
                                        )
                                        .modifier(OffsetModifier { value in
                                            DispatchQueue.main.async {
                                                animationModel.setOffset(for: section.index, value: value)
                                            }
                                        })
                                        .onDisappear {
                                            DispatchQueue.main.async {
                                                animationModel.setOffset(for: section.index, value: nil)
                                            }
//                                            if section.index == 11 {
//                                                lastHeaderBottom = nil
//                                            }
                                        }
//                                        .modifier(
//                                            SizeModifier { rect in
//                                                if section.index == 11 {
//                                                    lastHeaderBottom = rect.maxY
//                                                    print("lastHeaderBottom: \(lastHeaderBottom)")
//                                                }
//                                            }
//                                        )
                                    }
//                                    ,
//                                    footer: {
//                                        Rectangle()
//                                            .fill(Color.red)
//                                            .frame(height: 10)
////                                            .modifier(
////                                                SizeModifier { rect in
////                                                    if section.index == 11 {
////                                                        lastFooterTop = rect.minY
////                                                        print("lastFooterTop: \(lastFooterTop)")
////                                                    }
////                                                }
////                                            )
////                                            .onDisappear {
////                                                if section.index == 11 {
////                                                    lastFooterTop = nil
////                                                }
////                                            }
//                                    }
                                )
                                .id(section.id)
                                .listRowInsets(EdgeInsets())
                            }

                            // TODO: Handle if in last section.count != 0

                            Rectangle()
                                .fill(Color.screenBackground)
                                .frame(
                                    minHeight: max(0, geometryProxy.frame(in: .local).height - 44 - lastSection.reduce(0.0, +))
                                )
                        }
                    }
                    .onChange(of: selectedDay) { changeSelectedDay($0, proxy: proxy) }
                    .onChange(of: selectedWeek) { changeSelectedWeek($0, proxy: proxy) }
                    .overlay(
                        VStack {
                            Text("\(lastSection.reduce(0.0, +))")
//                            Text("\(lastFooterTop ?? -999)")
//                            Text("\(spacerSize(tableHeight: geometryProxy.frame(in: .local).height))")
                        }
                    )
                }
                .listStyle(.grouped)
                .background(Color.screenBackground)

            }
        }
    }

    func spacerSize(tableHeight: CGFloat) -> CGFloat {
        if let lastHeaderBottom = lastHeaderBottom, let lastFooterTop = lastFooterTop {
            let diff = lastHeaderBottom - lastFooterTop
            if diff <= 0 {
                return tableHeight - 44 - diff
            } else {
                return 0
            }
        } else {
            return 0
        }
    }

    func lastSectionOffsetModifiers(index: Int, height: CGFloat) {
        if lastSection[safe: index] == nil {
            lastSection.append(height)
        } else {
            lastSection[index] = height
        }
    }

    func changeSelectedDay(_ newValue: Lesson.Day?, proxy: ScrollViewProxy) {
        guard let newSelectedDay = newValue else {
            return
        }
        withAnimation {
            // If scrolling from bottom to top is lagging
            proxy.scrollTo(
                GroupLessons.State.Section.id(
                    week: displayedWeek,
                    day: newSelectedDay
                ),
                anchor: .top
            )
        }
        selectedDay = nil
    }

    func changeSelectedWeek(_ newValue: Lesson.Week?, proxy: ScrollViewProxy) {
        guard let newSelectedWeek = newValue else {
            return
        }
        withAnimation {
            proxy.scrollTo(
                GroupLessons.State.Section.id(
                    week: newSelectedWeek,
                    day: displayedDay
                ),
                anchor: .top
            )
        }
        selectedWeek = nil
    }

    func sectionHeader(day: Lesson.Day, week: Lesson.Week) -> some View {
        HStack {
            Text("\(day.fullDescription). \(week.description)")
                .font(.system(.headline))
                .foregroundColor(.black)
                .padding(.horizontal)
                .padding(.top)
                .textCase(nil)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            Spacer()
        }
        .frame(height: 44)
    }

}

struct HeaderTest: View {

    @ObservedObject var animation: AnimationViewModel
    let groupName: String
    @Binding var selectedWeek: Lesson.Week?
    @Binding var selectedDay: Lesson.Day?

    @Binding var displayedWeek: Lesson.Week
    @Binding var displayedDay: Lesson.Day

    var body: some View {
        VStack(spacing: 0) {
            GroupTitleView(
                title: groupName
            )

            GroupLessonsWeekPicker(
                selectedWeek: $selectedWeek,
                displayedWeek: $displayedWeek
            )

            GroupLessonsDayPicker(
                selectedDay: $selectedDay,
                displayedDay: $displayedDay
            )
        }
//        .safeAreaInset(edge: .top, content: {
//            Rectangle().fill(.red)
//        })
//        .ignoresSafeArea(.container, edges: .top)
        .onChange(of: animation.position) { newValue in
//            print(newValue)
            DispatchQueue.main.async {
//                withAnimation(.easeInOut(duration: 0.5)) {
                    displayedDay = newValue.day
                    displayedWeek = newValue.week

//                }
            }
        }
//        .background(Color.clear)
//        .clipped()
//        .edge
//        .edgesIgnoringSafeArea(.top)
//        .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 2)

//        .padding(.bottom, 4)
    }

}
