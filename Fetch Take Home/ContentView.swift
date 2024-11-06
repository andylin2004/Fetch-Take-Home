//
//  ContentView.swift
//  Fetch Take Home
//
//  Created by Andy Lin on 9/25/24.
//

import SwiftUI

// this view hosts the whole list, including the navigation bar. This list uses a subview for each section. This view also handles the initial task of getting all remote items
struct ContentView: View {
    @StateObject var viewModel = ContentView_ViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadingStatus {
                case .loaded(let remoteItemsByListId):
                    List(remoteItemsByListId.keys.sorted(), id: \.self) { listId in
                        if let dictValues = remoteItemsByListId[listId] {
                            ListIDGroupView(listId: listId, remoteItems: dictValues)
                        }
                    }
                    .listStyle(.sidebar)
                    .refreshable {
                        await viewModel.loadItems()
                    }
                case .error(let error):
                    ContentUnavailableView {
                        Label("Unable to Load Items", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.localizedDescription)
                    } actions: {
                        Button {
                            Task {
                                await viewModel.loadItemsFromErrorOrNotLoaded()
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
            await viewModel.loadItemsFromErrorOrNotLoaded()
        }
    }
    
    // this view is here because each section of a list has a disclosure header that allows the rest of the list to show up or disappear
    private struct ListIDGroupView: View {
        var listId: Int
        
        var remoteItems: [RemoteItem]
        @State var isExpanded = false
        
        var body: some View {
            // we only make a section if the remote items for
            if !remoteItems.isEmpty {
                Section("List \(listId)", isExpanded: $isExpanded) {
                    ForEach(remoteItems.sortByName()) { item in
                        Text("\(item.name ?? "")")
                    }
                }
                .headerProminence(.increased)
            }
        }
    }
}

#Preview {
    ContentView()
}
