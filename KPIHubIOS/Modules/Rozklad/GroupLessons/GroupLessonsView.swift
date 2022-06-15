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

    @State var savedOffsets: [CGFloat?] = Array(
        repeating: nil,
        count: GroupLessons.State.Section.Position.count
    )
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
        var visibleSections: [Bool] = Array(
            repeating: false,
            count: GroupLessons.State.Section.Position.count
        )

        func setOffset(for index: Int, value: CGFloat?) {

            if visibleSections[index] {
                if offsets[index] == value {
                    return
                }
                offsets[index] = value

            } else {
                print("Updating dismissed values for section \(index)")
                offsets[index] = nil
                return
            }
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
                let value = min(max(0, v2()), 11)
//                let value = calculateTopIndex(offsets: self.offsets)

                print(value)
                let newPosition = GroupLessons.State.Section.Position(index: value)
                DispatchQueue.main.async { [self, renderedPosition] in
                    if newPosition != renderedPosition {
                        position = newPosition
                    }
                }
                renderedPosition = newPosition
            }
        }

        func calculateTopIndex(offsets: [CGFloat?]) -> Int {
            let target: CGFloat = 169.0

            if offsets.compactMap({ $0 }).count <= 1, let index = offsets.firstIndex(where: { $0 != nil }) {
                return index

            } else if let firstIndex = offsets.firstIndex(where: { $0 ?? 0 > target + 1 }) {
                let result = max(firstIndex - 1, 0)
                return result

            } else if let lastIndex = offsets.lastIndex(where: { $0 ?? CGFloat.infinity < target - 1 }) {
                let result = min(lastIndex + 1, GroupLessons.State.Section.Position.count - 1)
                return result

            } else {
                let result = offsets.count - 1
                return result
            }
        }

        var lastElement: (Int, CGFloat)?

        func v2() -> Int {
            let target: CGFloat = 169.0
            let offsets = offsets
            let numberOfElements = offsets.compactMap { $0 }.count
//            return 0

            if numberOfElements != 0 {
                let index = offsets.firstIndex(where: { $0 != nil })!
                let element = offsets[index]!
                if numberOfElements == 1 {
                    lastElement = (index, element)
                }
                if element <= target && element >= target - 44 {
                    return index
                } else {
                    if element <= target - 44 {
                        return index + 1
                    } else {
                        return index - 1
                    }
                }

            } else if let lastElement = lastElement {
                print("lastElement \(lastElement)")
                if lastElement.1 < target {
                    return lastElement.0
                } else {
                    return lastElement.0 - 1
                }
            }

            return 0
        }

    }

    @ObservedObject var animationModel: AnimationViewModel = .init()

    init(store: Store<GroupLessons.State, GroupLessons.Action>) {
        self.store = store

        UITableView.appearance().sectionHeaderTopPadding = 0
    }

    var body: some View {
//        print("render body")
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    GroupTitleView(
                        title: viewStore.groupName
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
                .onChange(of: animationModel.position) { newValue in
                    //                        DispatchQueue.global(qos: .userInteractive).async {
                    //                            let some = newValue.map { "\($0?.rounded(.down) ?? 0)" }.joined(separator: " | ")
                    print(newValue)
                    DispatchQueue.main.async {
                        displayedDay = newValue.day
                        displayedWeek = newValue.week

                    }
                    //                        }
                    //                        DispatchQueue.main.async { [self] in
                    //                            let topIndex = calculateTopIndex(offsets: newValue)
                    //                            let sectionPosition = GroupLessons.State.Section.Position(index: topIndex)
                    //                            if renderedPosition != sectionPosition {
                    //                                print("Changed")
//                                                    displayedDay = sectionPosition.day
//                                                    displayedWeek = sectionPosition.week
                    //                            }
                    //                            renderedPosition = sectionPosition
                    //                        }
                }

                scrollView
//                    .listRowInsets(SwiftUI.EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    //                    .listStyle(.inset)
//                    .onChange(of: calculateTopIndex(offsets: offsets), perform: { value in
//                        print(value)
//                        let sectionPosition = GroupLessons.State.Section.Position(index: value)
//                        if renderedPosition != sectionPosition {
//                            print("Changed")
//                            displayedDay = sectionPosition.day
//                            displayedWeek = sectionPosition.week
//                        }
//                        renderedPosition = sectionPosition
//                    })


            }
            .navigationBarHidden(true)
            .onAppear {
                viewStore.send(.onAppear)
//                offsets = savedOffsets
            }
//            .onDisappear {
//                savedOffsets = offsets
//            }
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
                                                                animationModel.setOffset(for: section.index, value: value)
//                                                            }
                                                        }
                                                }
                                            }
                                        )
                                        .onAppear {
//                                            print("onAppear \(section.index)")
                                            animationModel.visibleSections[section.index] = true
                                        }
                                        .onDisappear {
//                                            print("onDisappear \(section.index)")
                                            animationModel.setOffset(for: section.index, value: nil)

                                            animationModel.visibleSections[section.index] = false
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




                                //                                    Section(
                                //                                        content: {
                                ////                                            ForEach(section.lessonCells, id: \.self) { item in
                                ////                                                //                                                    HStack {
                                ////                                                //                                                        Text("\(item.lesson.names[0])")
                                ////                                                //                                                        Spacer()
                                ////                                                //                                                    }
                                ////                                                //                                                    .frame(height: 120)
                                ////                                                TestCell()
                                ////
                                ////                                                    .id(item.id)
                                ////
                                ////                                            }
                                //                                            //                                                ForEach(section.les)
                                //
                                //                                        },
                                //                                        header: {
                                //
                                //                                        }
                                //                                    )
                                //                                    .listRowInsets(EdgeInsets())

                            }

                            // TODO: Handle if in last section.count != 0
                            Rectangle()
                                .fill(Color.screenBackground)
                                .frame(minHeight: geometryProxy.frame(in: .local).height - 44)
                        }

                    }
                    .coordinateSpace(name: "SCROLL")
//                    .onChange(of: selectedDay) { newValue in
//                        guard let newSelectedDay = newValue else {
//                            return
//                        }
//                        withAnimation {
//                            // If scrolling from bottom to top is lagging
//                            proxy.scrollTo(
//                                GroupLessons.State.Section.id(
//                                    week: displayedWeek,
//                                    day: newSelectedDay
//                                ),
//                                anchor: .top
//                            )
//                        }
//                        selectedDay = nil
//                    }
//                    .onChange(of: selectedWeek) { newValue in
//                        guard let newSelectedWeek = newValue else {
//                            return
//                        }
//                        withAnimation {
//                            proxy.scrollTo(
//                                GroupLessons.State.Section.id(
//                                    week: newSelectedWeek,
//                                    day: displayedDay
//                                ),
//                                anchor: .top
//                            )
//                        }
//                        selectedWeek = nil
//                    }
                }
                .listStyle(.grouped)
                .background(Color.screenBackground)
            }
        }
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

    func calculateTopIndex(offsets: [CGFloat?]) -> Int {
        let target: CGFloat = 169.0

        if offsets.compactMap({ $0 }).count <= 1, let index = offsets.firstIndex(where: { $0 != nil }) {
            return index

        } else if let firstIndex = offsets.firstIndex(where: { $0 ?? 0 > target + 1 }) {
            let result = max(firstIndex - 1, 0)
            return result

        } else if let lastIndex = offsets.lastIndex(where: { $0 ?? CGFloat.infinity < target - 1 }) {
            let result = min(lastIndex + 1, GroupLessons.State.Section.Position.count - 1)
            return result

        } else {
            let result = offsets.count - 1
            return result
        }
    }

}
//
//struct HeaderTest: View {
//
//    @ObservedObject var animation: GroupLessonsView.AnimationViewModel
//
//    var body: some View {
//        VStack(spacing: 0) {
//            GroupTitleView(
//                title: viewStore.groupName
//            )
//
//            GroupLessonsWeekPicker(
//                selectedWeek: $selectedWeek,
//                displayedWeek: $displayedWeek
//            )
//
//            GroupLessonsDayPicker(
//                selectedDay: $selectedDay,
//                displayedDay: $displayedDay
//            )
//        }
//        .onChange(of: animationModel.position) { newValue in
//            //                        DispatchQueue.global(qos: .userInteractive).async {
//            //                            let some = newValue.map { "\($0?.rounded(.down) ?? 0)" }.joined(separator: " | ")
//            print(newValue)
//            displayedDay = newValue.day
//            displayedWeek = newValue.week
//            //                        }
//            //                        DispatchQueue.main.async { [self] in
//            //                            let topIndex = calculateTopIndex(offsets: newValue)
//            //                            let sectionPosition = GroupLessons.State.Section.Position(index: topIndex)
//            //                            if renderedPosition != sectionPosition {
//            //                                print("Changed")
//            //                                                    displayedDay = sectionPosition.day
//            //                                                    displayedWeek = sectionPosition.week
//            //                            }
//            //                            renderedPosition = sectionPosition
//            //                        }
//        }
//
//    }
//}
