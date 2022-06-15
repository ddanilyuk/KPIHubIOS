//
//  GroupLessonsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct GroupLessonsView: View {

    @State var selectedWeek: Lesson.Week?
    @State var selectedDay: Lesson.Day?

    @State var displayedWeek: Lesson.Week = .first
    @State var displayedDay: Lesson.Day = .monday

//    @State var savedOffsets: [CGFloat?] = Array(
//        repeating: nil,
//        count: GroupLessons.State.Section.Position.count
//    )
//    @State var offsets: [CGFloat?] = Array(
//        repeating: nil,
//        count: GroupLessons.State.Section.Position.count
//    )
//    @State var visibleSections: [Bool] = Array(
//        repeating: false,
//        count: GroupLessons.State.Section.Position.count
//    )
//    @State var renderedPosition: GroupLessons.State.Section.Position = .init(week: .first, day: .monday)

    let store: Store<GroupLessons.State, GroupLessons.Action>


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
        var visibleSections: [Bool] = Array(
            repeating: false,
            count: GroupLessons.State.Section.Position.count
        )

        var task: Task<(), Never>?

//        func debounced(_ string: String) {
//            task?.cancel()
//
//            task = Task {
//                do {
//                    try await Task.sleep(nanoseconds: 1)
//                    logger.log("result \(string)")
//                } catch {
//                    logger.log("canceled \(string)")
//                }
//            }
//        }

        func save() {
            savedOffsets = offsets
        }

        func restore() {
            offsets = savedOffsets
            render()
        }

        func setOffset(for index: Int, value: CGFloat?) {

//            print(Date().timeIntervalSince1970)
            if offsets[index] == value {
                return
            }
            offsets[index] = value
            render()
        }

        func render() {
            let debug = offsets.map { optionalFloat in
                if let float = optionalFloat {
                    return "\(float.rounded())"
                } else {
                    return "nil"
                }
            }
                .joined(separator: " | ")
            print(debug)
            DispatchQueue.global(qos: .userInteractive).async { [self] in
                let value = min(max(0, v3()), 11)
                print(value)
                let newPosition = GroupLessons.State.Section.Position(index: value)
                if newPosition != renderedPosition {
                    DispatchQueue.main.async { [self] in
                        position = newPosition
                    }
                }
                renderedPosition = newPosition
            }
        }

//        func calculateTopIndex(offsets: [CGFloat?]) -> Int {
//            let target: CGFloat = 169.0
//
//            if offsets.compactMap({ $0 }).count <= 1, let index = offsets.firstIndex(where: { $0 != nil }) {
//                return index
//
//            } else if let firstIndex = offsets.firstIndex(where: { $0 ?? 0 > target + 1 }) {
//                let result = max(firstIndex - 1, 0)
//                return result
//
//            } else if let lastIndex = offsets.lastIndex(where: { $0 ?? CGFloat.infinity < target - 1 }) {
//                let result = min(lastIndex + 1, GroupLessons.State.Section.Position.count - 1)
//                return result
//
//            } else {
//                let result = offsets.count - 1
//                return result
//            }
//        }

        var lastElement: (Int, CGFloat)?

        func v2() -> Int {
            let target: CGFloat = 169.0 // 125
            let offsets = offsets
            let numberOfElements = offsets.compactMap { $0 }.count

            if numberOfElements != 0 {
                let index = offsets.firstIndex(where: { $0 != nil })!
                let element = offsets[index]!
                if numberOfElements == 1 {
                    lastElement = (index, element)
                    if element < target {
                        return index
                    } else {
                        return index - 1
                    }
                }
                if element < target {
                    print("First")
                    let index = offsets.lastIndex(where: { value in
                        if let value = value {
                            return value < target
                        } else {
                            return false
                        }
                    })!
                    return index
                } else {
                    print("Second")
                    return index - 1
                    if let next = offsets[safe: index + 1], let value = next {
                        print(value)
                        if value <= target {
                            return index + 1
                        } else {
                            return index
                        }
                    }

                }
//                switch element {
//                case (target - 44...target):
//                    return index
//                case ...(target - 44):
//                    return index + 1
//                default:
//                    return index - 1
//                }

            } else if let lastElement = lastElement {
                if lastElement.1 < target {
                    return lastElement.0
                } else {
                    return lastElement.0 - 1
                }
            }

            return 0
        }

        struct LastShownElement {
            var index: Int
            var value: CGFloat
        }

        var lastShownElement: LastShownElement?

        func v3() -> Int {
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

    var animationModel: AnimationViewModel = .init()

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
                print("Screen disapper")
            }
        }
    }

//    var header:

    var scrollView: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geometryProxy in
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(viewStore.sections, id: \.id) { section in

//                                VStack(spacing: 0) {
//                                    sectionHeader(
//                                        day: section.position.day,
//                                        week: section.position.week
//                                    )
//                                    .listRowInsets(EdgeInsets())
//                                    .listRowSeparator(.hidden)
////                                    .id(section.id)
//
//                                    ForEachStore(
//                                        self.store.scope(
//                                            state: \.sections[section.index].lessonCells,
//                                            action: GroupLessons.Action.lessonCells(id:action:)
//                                        ),
//                                        content: LessonCellView.init(store:)
//                                    )
//                                }
                                Section(
                                    content: {
                                        ForEachStore(
                                            self.store.scope(
                                                state: \.sections[section.index].lessonCells,
                                                action: GroupLessons.Action.lessonCells(id:action:)
                                            ),
                                            content: LessonCellView.init(store:)
                                        )
                                    },
                                    header: {
                                        sectionHeader(
                                            day: section.position.day,
                                            week: section.position.week
                                        )
                                        .overlay(
                                            ZStack {
                                                GeometryReader { proxy in
                                                    Color.clear//.red.opacity(0.2)
                                                        .onChange(of: proxy.frame(in: .global).minY) { value in
//                                                            print("\(section.index) \(value)")
//                                                            DispatchQueue.global(qos: .userInteractive).async { [self] in
//                                                            print(value - proxy.frame(in: .global).minY)
                                                            DispatchQueue.main.async {
                                                                animationModel.setOffset(for: section.index, value: value)
                                                            }
                                                        }
                                                }
                                            }
                                        )
//                                        .onAppear {
////                                            print("onAppear \(section.index)")
//                                            animationModel.visibleSections[section.index] = true
//                                        }
                                        .onDisappear {
//                                            print("onDisappear \(section.index)")
                                            DispatchQueue.main.async {
                                                print("header \(section.index) disappear")
                                                animationModel.setOffset(for: section.index, value: nil)
                                            }

//                                            animationModel.visibleSections[section.index] = false
//                                            animationModel.offsets[section.index] = nil

                                        }
                                    }
                                )
                                .id(section.id)


                                //                                    .overlay(
                                //
                                //                                    )


                                //                                    ZStack {
                                //                                        VStack(spacing: 0) {
                                //                                            sectionHeader(
                                //                                                day: section.position.day,
                                //                                                week: section.position.week
                                //                                            )
                                //                                            .listRowInsets(EdgeInsets())
                                //                                            .listRowSeparator(.hidden)
                                //                                            //                                        .background(Color.red)
                                //                                            .id(section.id)
                                //
                                //                                            ForEachStore(
                                //                                                self.store.scope(
                                //                                                    state: \.sections[section.index].lessonCells,
                                //                                                    action: GroupLessons.Action.lessonCells(id:action:)
                                //                                                ),
                                //                                                content: {
                                //                                                    LessonCellView(store: $0)
                                //                                                    //                                                    .id($0.id)
                                //                                                        .listRowInsets(EdgeInsets())
                                //                                                        .listRowSeparator(.hidden)
                                //                                                    //                                                .overlay(Color.blue)
                                //
                                //                                                }
                                //                                            )
                                //                                        }
                                //
                                //                                        GeometryReader { proxy in
                                //                                            Color.red.opacity(0.2)
                                //                                                .onChange(of: proxy.frame(in: .global).minY) { value in
                                //                                                    print("\(section.index) \(value)")
                                //                                                    animationModel.setOffset(for: section.index, value: value)
                                //                                                }
                                //                                        }
                                //                                        .onDisappear {
                                //                                            print("Overlay Disappear \(section.index)")
                                //                                        }
                                //                                    }



                                //                                    .onPreferenceChange(OffsetPreferenceKey.self) { value in
                                ////                                        print("Set value \(value) for index \(section.index)")
                                //                                        if visibleSections[section.index] {
                                //                                            offsets[section.index] = value
                                //                                        } else {
                                //                                            print("Updating dismissed values for section \(section.index)")
                                //                                            offsets[section.index] = nil
                                //                                        }
                                //                                    }


                                .listRowInsets(EdgeInsets())
                                //                                    .modifier(OffsetModifier { value in
                                //                                        animationModel.setOffset(for: section.index, value: value)
                                ////                                        DispatchQueue.main.async {
                                ////                                            if visibleSections[section.index] {
                                ////                                                offsets[section.index] = value
                                ////                                            } else {
                                ////                                                print("Updating dismissed values for section \(section.index)")
                                ////                                                offsets[section.index] = nil
                                ////                                            }
                                ////                                        }
                                //                                    })
                            }

                            // TODO: Handle if in last section.count != 0
                            Rectangle()
                                .fill(Color.screenBackground)
                                .frame(minHeight: geometryProxy.frame(in: .local).height - 44)
                        }

                    }
                    .coordinateSpace(name: "SCROLL")
                    .onChange(of: selectedDay) { changeSelectedDay($0, proxy: proxy) }
                    .onChange(of: selectedWeek) { changeSelectedWeek($0, proxy: proxy) }
                }
                .listStyle(.grouped)
                .background(Color.screenBackground)
            }
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

//    func calculateTopIndex(offsets: [CGFloat?]) -> Int {
//        let target: CGFloat = 169.0
//
//        if offsets.compactMap({ $0 }).count <= 1, let index = offsets.firstIndex(where: { $0 != nil }) {
//            return index
//
//        } else if let firstIndex = offsets.firstIndex(where: { $0 ?? 0 > target + 1 }) {
//            let result = max(firstIndex - 1, 0)
//            return result
//
//        } else if let lastIndex = offsets.lastIndex(where: { $0 ?? CGFloat.infinity < target - 1 }) {
//            let result = min(lastIndex + 1, GroupLessons.State.Section.Position.count - 1)
//            return result
//
//        } else {
//            let result = offsets.count - 1
//            return result
//        }
//    }

}

struct HeaderTest: View {

    @ObservedObject var animation: GroupLessonsView.AnimationViewModel
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
