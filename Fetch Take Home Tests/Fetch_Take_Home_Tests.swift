//
//  Fetch_Take_Home_Tests.swift
//  Fetch Take Home Tests
//
//  Created by Andy Lin on 12/3/24.
//

import Testing
@testable import Fetch_Take_Home

@MainActor
struct Fetch_Take_Home_Tests {
    
    let viewModel = ContentView_ViewModel(getDataProtocol: MockItemFetcher())

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        #expect(viewModel.loadingStatus == .notLoadedYet)
    }
    
    @Test func testLoadItem() async throws {
        await viewModel.loadItems()
        if case let .loaded(items) = viewModel.loadingStatus {
            let expectedItems = [
                1: [
                    RemoteItem(
                        id: 1,
                        listId: 1,
                        name: "Uno"
                    ),
                    RemoteItem(
                        id: 2,
                        listId: 1,
                        name: "UnoDos"
                    )
                ],
                2: [
                    RemoteItem(
                        id: 3,
                        listId: 2,
                        name: "Uno"
                    ),
                    RemoteItem(
                        id: 3,
                        listId: 2,
                        name: "UnoDos"
                    )
                ]
            ]
            #expect(items == expectedItems)
        }
    }
}
