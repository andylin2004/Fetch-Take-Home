//
//  RemoteItem.swift
//  Fetch Take Home
//
//  Created by Andy Lin on 9/25/24.
//

import Foundation

struct RemoteItem: Codable {
    let id: Int
    let listId: Int
    let name: String?
    
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
