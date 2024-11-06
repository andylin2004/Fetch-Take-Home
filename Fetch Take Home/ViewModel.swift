//
//  ViewModel.swift
//  Fetch Take Home
//
//  Created by Andy Lin on 11/6/24.
//

import Foundation

@MainActor
class ContentView_ViewModel: ObservableObject {
    // this variable indicates the view state (loaded, unloaded, error) as well as a container for the view array
    @Published var loadingStatus: LoadingStatus = .notLoadedYet
    
    enum LoadingStatus {
        case notLoadedYet
        case loaded([Int : [RemoteItem]])
        case error(Error)
    }
    
    // this function will attempt to load in all remote items from the remote source, or set a view state variable to show an error screen
    func loadItems() async {
        do {
            let result = try await RemoteItem.pullItems()
            loadingStatus = .loaded(result.filterAllEmptyOrNullNames().groupByListId())
        } catch {
            loadingStatus = .error(error)
        }
    }
    
    // this function will attempt to load in all remote items from the remote source, or set a view state variable to show an error screen
    // should only be used if unloaded or on error screen
    func loadItemsFromErrorOrNotLoaded() async {
        loadingStatus = .notLoadedYet
        await loadItems()
    }
}
