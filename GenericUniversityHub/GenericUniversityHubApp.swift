//
//  GenericUniversityHubApp.swift
//  GenericUniversityHub
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import SwiftUI
import UniversityHubKit
import GroupPickerFeature
import RozkladFeature
import DesignKit
import ComposableArchitecture
import GeneralServices

/// This app represent modularity of UniversityHubKit.
/// New app for another university can be easily created
/// using predefined modules and ui complements.
@main
struct GenericUniversityHubApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: appDelegate.store)
                .accentColor(Color.red)
                .environment(\.designKit, DesignKit.custom)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store: StoreOf<AppFeature> = {
        Store(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: { dependencies in
            dependencies.rozkladServiceState = .mock()
        }
    }()
    
    private lazy var appDelegateStore = store.scope(
        state: \.appDelegate,
        action: \.appDelegate
    )
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        appDelegateStore.send(.didFinishLaunching(Bundle.main))
        return true
    }
}

extension DesignKit {
    static let custom = DesignKit(
        primaryColor: .red,
        backgroundColor: .pink.opacity(0.1),
        currentLessonColor: .red,
        nextLessonColor: .green
    )
}

@Reducer
struct AppDelegateFeature: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable {
        case didFinishLaunching(Bundle)
    }
    
    @Dependency(\.firebaseService) var firebaseService
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case let .didFinishLaunching(bundle):
                // firebaseService.setup(bundle)
                return .none
            }
        }
    }
}


@Reducer
struct AppFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var appDelegate = AppDelegateFeature.State()
        var destination: Destination.State?
    }
    
    enum Action {
        case appDelegate(AppDelegateFeature.Action)
        case destination(Destination.Action)
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
        
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
//                if userDefaultsService.get(for: .onboardingPassed) {
                state.destination = .main(RozkladFlow.State())
//                } else {
//                    state.destination = .onboarding(OnboardingFlow.State())
//                }
                return .run { send in
                    await send(.destination(.main(.onSetup)))
                }
                                
//            case .destination(.onboarding(.output(.done))):
//                state.destination = .main(MainFlow.State())
//                return .none
                
            case .appDelegate:
                return .none
                
            case .destination:
                return .none
            }
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateFeature()
        }
        core
            .ifLet(\.destination, action: \.destination) {
                Destination()
            }
    }
}

extension AppFeature {
    @Reducer
    struct Destination: Reducer {
        enum State: Equatable {
//            case onboarding(OnboardingFlow.State)
            case main(RozkladFlow.State)
        }
        
        enum Action {
//            case onboarding(OnboardingFlow.Action)
            case main(RozkladFlow.Action)
        }
        
        var body: some ReducerOf<Self> {
//            Scope(state: \.onboarding, action: \.onboarding) {
//                OnboardingFlow()
//            }
            Scope(state: \.main, action: \.main) {
                RozkladFlow()
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    var body: some View {
        switch store.destination {
//        case .groupPicker:
//            if let childStore = store.scope(
//                state: \.destination?.groupPicker,
//                action: \.destination.groupPicker
//            ) {
//                GroupPickerView(store: childStore)
//            }

        case .main:
            if let childStore = store.scope(
                state: \.destination?.main,
                action: \.destination.main
            ) {
                RozkladFlowView(store: childStore)
            }
            
        case .none:
            EmptyView()
        }
    }
}

@ViewAction(for: RozkladLessonFeature.self)
struct RozkladLessonView: View {
    @Environment(\.colorScheme) var colorScheme
    let store: StoreOf<RozkladLessonFeature>
    
    init(store: StoreOf<RozkladLessonFeature>) {
        self.store = store
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            backgroundView
            contentView
        }
        .onTapGesture {
            send(.onTap)
        }
        .padding()
        // TODO: assets
//        .background(Color.screenBackground)
    }

//    var timeView: some View {
//        GeometryReader { proxy in
//            RoundedRectangle(cornerRadius: 2)
//                .fill(Color.gray.opacity(0.2))
//                .if(viewStore.mode.isCurrent) { view in
//                    view.overlay(alignment: .top) {
//                        LinearGradientAnimatableView()
//                            .frame(height: viewStore.mode.percent * proxy.frame(in: .local).height)
//                    }
//                }
//        }
//        .frame(width: viewStore.mode.isCurrent ? 4 : 2, alignment: .center)
//        .frame(minHeight: 20)
//    }

    @ViewBuilder
    var backgroundView: some View {
        switch store.status {
        case .current:
            BorderGradientBackgroundView()
                .overlay(alignment: .topTrailing) {
                    LessonBadgeView(mode: .current)
                }

        case .next:
            Rectangle()
                .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
                .overlay(alignment: .topTrailing) {
                    LessonBadgeView(mode: .next)
                }

        case .idle:
            Rectangle()
                .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
        }
    }

    var contentView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(store.lesson.names.joined(separator: ", "))")
                .font(.system(.callout).bold())
                .lineLimit(2)
            
            if let teachers = store.lesson.teachers, !teachers.isEmpty {
                ForEach(teachers, id: \.self) { teacher in
                    SmallTagView(
                        icon: Image(systemName: "person"),
                        text: teacher,
                        color: .pink
                    )
                }
            }
            
            if store.lesson.locations != nil || !store.lesson.type.isEmpty {
                HStack {
                    if let locations = store.lesson.locations {
                        SmallTagView(
                            icon: Image(systemName: "location"),
                            text: locations.first ?? "-",
                            color: .teal
                        )
                    }
                    if !store.lesson.type.isEmpty {
                        SmallTagView(
                            icon: Image(systemName: "graduationcap"),
                            text: store.lesson.type,
                            color: .cyan
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}
