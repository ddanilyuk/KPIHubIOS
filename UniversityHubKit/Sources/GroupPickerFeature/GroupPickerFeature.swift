//
//  GroupPickerStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Services

@Reducer
public struct GroupPickerFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        let mode: Mode
        var groups: [GroupResponse] = []
        var searchedGroups: [GroupResponse] = []
        var selectedGroup: GroupResponse?
        var searchPresented = false
        var searchedText: String = ""
        var isLoading = true
        @Presents var alert: AlertState<Action.Alert>?
        
        public init(mode: Mode) {
            self.mode = mode
        }
    }
    
    public enum Action: ViewAction {
        case alert(PresentationAction<Alert>)
        case view(View)
        case local(Local)
        case output(Output)
        
        public enum Output {
            case done
        }
        
        public enum Local {
            case allGroupsResult(Result<[GroupResponse], Error>)
            case lessonsResult(Result<[Lesson], Error>)
        }
        
        public enum Alert: Equatable { }
        
        public enum View: BindableAction {
            case onAppear
            case refresh
            case groupSelected(GroupResponse)
            case binding(BindingAction<State>)
        }
    }

    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.rozkladServiceState) var rozkladServiceState
    @Dependency(\.analyticsService) var analyticsService
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .local(localAction):
                return handleLocalAction(state: &state, action: localAction)
                
            case .output:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - ViewAction
private extension GroupPickerFeature {
    func handleViewAction(state: inout State, action: Action.View) -> Effect<Action> {
        switch action {
        case .onAppear:
            analyticsService.track(Event.Onboarding.groupPickerAppeared)
            return loadGroups()
            
        case .refresh:
            return loadGroups()
            
        case let .groupSelected(group):
            state.isLoading = true
            state.searchPresented = false
            state.selectedGroup = group
            analyticsService.track(Event.Onboarding.groupPickerSelect)
            return getLessons(for: group)
            
        case .binding(\.searchedText):
            if state.searchedText.isEmpty {
                state.searchedGroups = state.groups
            } else {
                let filtered = state.groups.filter { group in
                    let groupName = group.name.lowercased()
                    let searchedText = state.searchedText.lowercased()
                    return groupName.contains(searchedText)
                }
                state.searchedGroups = filtered
            }
            return .none
            
        case .binding:
            return .none
        }
    }
}

// MARK: - LocalAction
private extension GroupPickerFeature {
    func handleLocalAction(state: inout State, action: Action.Local) -> Effect<Action> {
        switch action {
        case let .allGroupsResult(.success(groups)):
            state.isLoading = false
            state.groups = groups
            state.searchedGroups = groups
            analyticsService.track(Event.Onboarding.groupsLoadSuccess)
            return .none

        case let .lessonsResult(.success(lessons)):
            if let selectedGroup = state.selectedGroup {
                rozkladServiceState.setState(ClientValue(.selected(selectedGroup), commitChanges: false))
                analyticsService.setGroup(selectedGroup)
            }
            state.isLoading = false
            rozkladServiceLessons.set(.init(lessons, commitChanges: false))
            analyticsService.track(Event.Rozklad.lessonsLoadSuccess(place: state.mode.eventPlace))
            return .send(.output(.done))

        case let .allGroupsResult(.failure(error)):
            state.isLoading = false
            state.alert = AlertState.error(error)
            analyticsService.track(Event.Onboarding.groupsLoadFailed)
            return .none
            
        case let .lessonsResult(.failure(error)):
            state.isLoading = false
            state.alert = AlertState.error(error)
            analyticsService.track(Event.Rozklad.lessonsLoadFailed(place: state.mode.eventPlace))
            return .none
        }
    }
}

// MARK: - API
private extension GroupPickerFeature {
    func loadGroups() -> Effect<Action> {
        .run { send in
            let groupsResult = await Result {
                try await rozkladServiceState.loadGroups()
            }
            await send(.local(.allGroupsResult(groupsResult)))
        }
    }
    
    func getLessons(for group: GroupResponse) -> Effect<Action> {
        .run { send in
            let result = await Result {
                try await rozkladServiceLessons.getLessons(group: group)
            }
            // Make keyboard hide to prevent tabBar opacity bugs
            try await Task.sleep(for: .milliseconds(300))
            await send(.local(.lessonsResult(result)))
        }
    }
}

// MARK: - Mode
extension GroupPickerFeature {
    public enum Mode {
        case onboarding
        case rozkladTab
        case campus
        
        var eventPlace: Event.Rozklad.Place {
            switch self {
            case .campus:
                return .campus
                
            case .rozkladTab:
                return .rozkladTab
                
            case .onboarding:
                return .onboarding
            }
        }
    }
}
