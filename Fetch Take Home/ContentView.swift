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
        List(remoteItemsByListId.keys.sorted(), id: \.self) { listId in
            if let items = remoteItemsByListId[listId] {
                Section(header: Text("List \(listId)")) {
                    ForEach(items) { item in
                        Text("\(item.name ?? "")")
                    }
                }
            }
        }
        .task {
            if let result = try? await RemoteItem.pullItems() {
                self.remoteItemsByListId = result.filterAllEmptyOrNullNames().groupByListId()
            }
        }
    }
}

#Preview {
    ContentView()
}
