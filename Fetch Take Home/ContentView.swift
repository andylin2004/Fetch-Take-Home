//
//  ContentView.swift
//  Fetch Take Home
//
//  Created by Andy Lin on 9/25/24.
//

import SwiftUI

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
    
    struct ListIDGroupView: View {
        var listId: Int
        
        @Binding var remoteItemsByListId: [Int : [RemoteItem]]
        @State var isExpanded = false
        
        var body: some View {
            if let items = remoteItemsByListId[listId]?.sortByName() {
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
