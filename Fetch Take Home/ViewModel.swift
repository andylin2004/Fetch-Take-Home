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
    
    enum LoadingStatus: Equatable {
        case notLoadedYet
        case loaded([Int : [RemoteItem]])
        case error(Error)
        
        static func ==(lhs: LoadingStatus, rhs: LoadingStatus) -> Bool {
            switch (lhs, rhs) {
            case let (.loaded(lhsD), .loaded(rhsD)):
                return lhsD == rhsD
            case let (.error(lhsE), .error(rhsE)):
                return true
            case (.notLoadedYet, .notLoadedYet):
                return true
            default:
                return false
            }
        }
    }
    
    let getDataProtocol: any GetDataProtocol
    
    // this function will attempt to load in all remote items from the remote source, or set a view state variable to show an error screen
    func loadItems() async {
        do {
            let result = try await getDataProtocol.pullItems()
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
    
    init(getDataProtocol: any GetDataProtocol = ItemFetcher()) {
        self.getDataProtocol = getDataProtocol
    }
}

protocol GetDataProtocol {
    func pullItems() async throws -> [RemoteItem]
}
