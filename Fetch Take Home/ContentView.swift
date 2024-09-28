//
//  ContentView.swift
//  Fetch Take Home
//
//  Created by Andy Lin on 9/25/24.
//

import SwiftUI

// this view hosts the whole list, including the navigation bar. This list uses a subview for each section. This view also handles the inital task of getting all remote items
struct ContentView: View {
    @State var remoteItemsByListId: [Int : [RemoteItem]] = [:]
    
    var body: some View {
        NavigationStack {
            List(remoteItemsByListId.keys.sorted(), id: \.self) { listId in
                ListIDGroupView(listId: listId, remoteItemsByListId: $remoteItemsByListId)
            }
            .listStyle(.sidebar)
            .navigationTitle("Remote Items")
        }
        .task {
            if let result = try? await RemoteItem.pullItems() {
                self.remoteItemsByListId = result.filterAllEmptyOrNullNames().groupByListId()
            }
        }
    }
    
    // this view is here because each section of a list has a disclosure header that allows the rest of the list to show up or disappear
    struct ListIDGroupView: View {
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
}

#Preview {
    ContentView()
}
