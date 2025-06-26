//
//  JSONLocationDataStore.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import Foundation

/// Persistencia local basada en un único JSON en Documents/.
final class JSONLocationDataStore: LocationDataStore {

    private let url: URL

    init(fileName: String = "locations.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = docs.appendingPathComponent(fileName)
    }

    // MARK: - LocationDataStore

    func fetchLocations() -> [Location] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([Location].self, from: data)) ?? []
    }

    func save(_ locations: [Location]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(locations) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
