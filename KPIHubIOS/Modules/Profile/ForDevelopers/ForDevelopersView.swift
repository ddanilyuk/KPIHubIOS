//
//  ForDevelopersView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI
import ComposableArchitecture

// FeatureCoordinator
//  Capable of
//      - popover
//      - sheet
//      - alert

// FlowCoordinator
// Capable of
//      - navigationDestination

struct FlowCoordinator: Reducer {
    struct State: Equatable {
        var feature: SomeFeature.State// Feature
        var path = StackState<Path.State>()
        
//        init() {
////            path.append(.profileHome(ProfileHome.State()))
//        }
    }
    
    enum Action: Equatable {
        case delegate(Delegate)
        case feature(SomeFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
        
        enum Delegate: Equatable {
            case selectRozkladTab
            case selectCampusTab
        }
    }
    
    struct Path: Reducer {
        enum State: Equatable {
            case profileHome(ProfileHome.State)
            case forDevelopers(ForDevelopers.State)
        }
        
        enum Action: Equatable {
            case profileHome(ProfileHome.Action)
            case forDevelopers(ForDevelopers.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: /State.profileHome, action: /Action.profileHome) {
                ProfileHome()
            }
            Scope(state: /State.forDevelopers, action: /Action.forDevelopers) {
                ForDevelopers()
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.feature, action: /Action.feature) {
            SomeFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .feature(.dismiss):
                state.path.append(.forDevelopers(ForDevelopers.State()))
                return .none
                
            case .feature:
                // Push or pop
                return .none
                
            case .path:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}

struct FlowCoordinatorView: View {
    let store: StoreOf<FlowCoordinator>
    
    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: FlowCoordinator.Action.path),
            root: {
                // TODO: Embed FeatureView here?
                // TODO: Do we need Root?
                SomeFeatureView(
                    store: store.scope(state: \.feature, action: FlowCoordinator.Action.feature)
                )
                    // .sheet
                    // .popover
                    // .fullscreen
            },
            destination: { destination in
                switch destination {
                case .profileHome:
                    CaseLet(
                        /FlowCoordinator.Path.State.profileHome,
                        action: FlowCoordinator.Path.Action.profileHome,
                        then: ProfileHomeView.init(store:)
                    )
                    
                case .forDevelopers:
                    CaseLet(
                        /FlowCoordinator.Path.State.forDevelopers,
                        action: FlowCoordinator.Path.Action.forDevelopers,
                        then: ForDevelopersView.init(store:)
                    )
                }
            }
        )
    }
}

struct ForDevelopersView: View {

    let store: StoreOf<ForDevelopers>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 32) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Привіт!")
                            .font(.title)

                        Text("Цей додаток з відкритим кодом. Вся детальна інформація у README.md в репозиторіях")
                        Text("Якщо є будь-які питання, напиши мені.")
                        
                        Button("Present") {
                            viewStore.send(.presentSome)
                        }
                        
                        Button("Push") {
                            viewStore.send(.pushSome)
                        }
                    }

                    gitHubSection

                    contactsSection
                }
                .padding(16)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
        .background(Color.screenBackground)
        .sheet(
            store: store.scope(state: \.$destination, action: ForDevelopers.Action.destination),
            state: /ForDevelopers.Destination.State.someFeature,
            action: ForDevelopers.Destination.Action.someFeature
        ) { store in
            SomeFeatureView(store: store)
        }
        .navigationDestination(
            store: store.scope(state: \.$destination, action: ForDevelopers.Action.destination),
            state: /ForDevelopers.Destination.State.someFeaturePush,
            action: ForDevelopers.Destination.Action.someFeaturePush
        ) { store in
            SomeFeatureView(store: store)
                .background(Color.red)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Для розробників")
    }

    var gitHubSection: some View {
        ProfileSectionView(
            title: "Github",
            content: {
                VStack(alignment: .leading, spacing: 20) {

                    ProfileCellView(
                        title: "Додаток:",
                        value: .link(
                            name: "KPIHubIOS",
                            url: URL(string: "https://github.com/ddanilyuk/KPIHubIOS")!
                        ),
                        image: {
                            Image("github")
                                .resizable()
                        },
                        imageBackgroundColor: .white
                    )

                    ProfileCellView(
                        title: "Сервер:",
                        value: .link(
                            name: "KPIHubServer",
                            url: URL(string: "https://github.com/ddanilyuk/KPIHubServer")!
                        ),
                        image: {
                            Image("github")
                                .resizable()
                        },
                        imageBackgroundColor: .white
                    )

                }
            }
        )
    }

    var contactsSection: some View {
        ProfileSectionView(
            title: "Контакти",
            content: {
                VStack(alignment: .leading, spacing: 20) {

                    ProfileCellView(
                        title: "Telegram:",
                        value: .link(
                            name: "@ddanilyuk",
                            url: URL(string: "https://t.me/ddanilyuk")!
                        ),
                        image: {
                            Image("telegram")
                                .resizable()
                        },
                        imageBackgroundColor: Color.yellow
                    )

                    ProfileCellView(
                        title: "Email:",
                        value: .link(
                            name: "danis.danilyuk@gmail.com",
                            url: URL(string: "mailto:danis.danilyuk@gmail.com")!
                        ),
                        image: {
                            Image(systemName: "mail")
                                .foregroundColor(.green.lighter(by: 0.9))
                        },
                        imageBackgroundColor: .green
                    )

                }
            }
        )
    }

}

// MARK: - Preview

struct ForDevelopersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ForDevelopersView(
                store: Store(
                    initialState: ForDevelopers.State(),
                    reducer: ForDevelopers()
                )
            )
        }
    }
}
