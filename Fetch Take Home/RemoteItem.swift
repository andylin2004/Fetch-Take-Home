//
//  RemoteItem.swift
//  Fetch Take Home
//
//  Created by Andy Lin on 9/25/24.
//

import Foundation

// this struct allows us to decode the remoteitem from the remote source, as well as pull from the remote source
// struct variable names are the same as the json names, as this will make decoding super easy for us
struct RemoteItem: Codable, Identifiable {
    let id: Int
    let listId: Int
    let name: String?
    
    // this is where we pull the remote items from the remote source
    static func pullItems() async throws -> [RemoteItem] {
        let url = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json")
        if let url = url {
            let (pulledData, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            
            return try decoder.decode([RemoteItem].self, from: pulledData)
        } else {
            throw URLError(.badURL)
        }
    }
}

// we have a few special functions for arrays of RemoteItems, such as filtering empty and null names, as well as grouping lists by list id for later steps
extension [RemoteItem] {
    // from an array of remote items, we just filter and return an array with the remoteitems except for the items with empty names or null names
    func filterAllEmptyOrNullNames() -> [RemoteItem] {
        return self.filter { item in
            if let name = item.name {
                return !name.isEmpty
            } else {
                return false
            }
        }
    }
    
    // given a list of remoteitems, we return a dictionary of ints (list ids) that map to an array of remote items
    func groupByListId() -> [Int : [RemoteItem]] {
        var dict: [Int : [RemoteItem]] = [:]
        
        for item in self {
            // the default thing is here in case there is null for a dictionary key, where we'll just make an empty array
            dict[item.listId, default: []].append(item)
        }
        
        return dict
    }
    
    // given an array of remoteitems, this will just sort the remoteitem arrays by the name property
    func sortByName() -> [RemoteItem] {
        return self.sorted { a, b in
            a.name ?? "" < b.name ?? ""
        }
    }
}
