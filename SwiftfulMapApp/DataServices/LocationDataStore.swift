//
//  LocationsViewModel.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//
import Foundation

protocol LocationDataStore {
    /// Devuelve todas las Locations persistidas (puede estar vacío).
    func fetchLocations() -> [Location]

    /// Persiste el array completo (sustituye el estado anterior).
    func save(_ locations: [Location])
}
