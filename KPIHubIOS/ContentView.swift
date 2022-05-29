//
//  ContentView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 19.05.2022.
//

import SwiftUI
import Routes
import URLRouting

struct GroupResponse: Codable {
    var groups: [Group]
}

struct Group: Codable {
    let id: String
    let name: String
}

class ViewModel: ObservableObject {
    @Published var groups: [Group] = []

    let apiClient: URLRoutingClient<RootRoute>

    init(apiClient: URLRoutingClient<RootRoute>) {
        self.apiClient = apiClient
    }

    @MainActor
    func fetch() async {
        do {
            self.groups = try await self.apiClient.decodedResponse(
                for: .api(.groups(.all)),
                as: GroupResponse.self
            ).value.groups
        } catch {

        }
    }
}

struct ContentView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(self.viewModel.groups, id: \.id) { group in
                    Text(group.name)
                }
            }
            .task { await viewModel.fetch() }
            .navigationTitle("Групи")
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var allGroupsResponse: GroupResponse {
        let groups = (1...100).map {
            Group(
                id: .init(),
                name: "Group \($0)"
            )
        }
        return GroupResponse(
            groups: groups
        )
    }

    static var apiClient: URLRoutingClient<RootRoute> {
        .failing
        .override(
            .api(.groups(.all)),
            with: { try .ok(allGroupsResponse) }
        )
    }

    static var previews: some View {
        ContentView(
            viewModel: ViewModel(
                apiClient: apiClient
            )
        )
    }
}
