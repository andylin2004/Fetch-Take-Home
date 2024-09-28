//
//  ContentView.swift
//  Fetch Take Home
//
//  Created by Andy Lin on 9/25/24.
//

import SwiftUI

// this view hosts the whole list, including the navigation bar. This list uses a subview for each section. This view also handles the initial task of getting all remote items
struct ContentView: View {
    // this variable contains all the remote items
    @State private var remoteItemsByListId: [Int : [RemoteItem]] = [:]
    
    // this variable indicates the view state (loaded, unloaded, error)
    @State private var loadingStatus: LoadingStatus = .notLoadedYet
    
    var body: some View {
        NavigationStack {
            Group {
                switch loadingStatus {
                case .loaded:
                    List(remoteItemsByListId.keys.sorted(), id: \.self) { listId in
                        ListIDGroupView(listId: listId, remoteItemsByListId: $remoteItemsByListId)
                    }
                    .listStyle(.sidebar)
                    .refreshable {
                        await loadItems()
                    }
                case .error(let error):
                    ContentUnavailableView {
                        Label("Unable to Load Items", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.localizedDescription)
                    } actions: {
                        Button {
                            Task {
                                loadingStatus = .notLoadedYet
                                await loadItems()
                            }
                        } label: {
                            Label("Try loading again?", systemImage: "arrow.clockwise")
                        }
                    }
                case .notLoadedYet:
                    ProgressView("LOADING")
                        .font(.body.smallCaps())
                }
            }
            .navigationTitle("Remote Items")
        }
        .task {
            loadingStatus = .notLoadedYet
            await loadItems()
        }
    }
    
    // this view is here because each section of a list has a disclosure header that allows the rest of the list to show up or disappear
    private struct ListIDGroupView: View {
        var listId: Int
        
        @Binding var remoteItemsByListId: [Int : [RemoteItem]]
        @State var isExpanded = false
        
        var body: some View {
            // we only make a section if the remote items for
            if let items = remoteItemsByListId[listId]?.sortByName(), !items.isEmpty {
                Section("List \(listId)", isExpanded: $isExpanded) {
                    ForEach(items) { item in
                        Text("\(item.name ?? "")")
                    }
                }
                .headerProminence(.increased)
            }
        }
    }
    
    private enum LoadingStatus {
        case notLoadedYet
        case loaded
        case error(Error)
    }
    
    // this function will attempt to load in all remote items from the remote source, or set a view state variable to show an error screen
    private func loadItems() async {
        do {
            let result = try await RemoteItem.pullItems()
            self.remoteItemsByListId = result.filterAllEmptyOrNullNames().groupByListId()
            loadingStatus = .loaded
        } catch {
            loadingStatus = .error(error)
        }
    }
}

#Preview {
    ContentView()
}
