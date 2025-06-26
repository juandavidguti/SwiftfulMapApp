//
//  LocationsViewModel.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

//
//  LocationsViewModel.swift
//  SwiftfulMapApp
//
//  Created by Nick Sarno on 11/27/21.
//

import Foundation
import MapKit
import SwiftUI
import Combine

class LocationsViewModel: ObservableObject {
    
    // All loaded locations
    @Published private(set) var locations: [Location] = []
    private let dataStore: LocationDataStore
    @Published var isPresentingForm: Bool = false
    var draftCoordinate: CLLocationCoordinate2D?
    
    // Current location on map
    @Published var mapLocation: Location {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    
    // Current region on map
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    // Show list of locations
    @Published var showLocationsList: Bool = false
    
    // Show location detail via sheet
    @Published var sheetLocation: Location? = nil
    
    init(dataStore: LocationDataStore = JSONLocationDataStore()) {
        self.dataStore = dataStore

        // Cargamos primero en una variable local para no acceder a `self`
        let stored = dataStore.fetchLocations()
        self.locations = stored

        if let first = stored.first {
            self.mapLocation = first
        } else {
            let placeholder = Location(
                title: "New Pin",
                subtitle: "",
                description: "",
                coordinate: CLLocationCoordinate2D(
                    latitude: 0,
                    longitude: 0
                ),
                link: "",
            )
            self.locations = [placeholder]
            self.mapLocation = placeholder
        }
        updateMapRegion(location: mapLocation)
    }
    
    private func updateMapRegion(location: Location) {
        withAnimation(.easeInOut) {
            mapRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: mapSpan)
        }
    }
    
    func toggleLocationsList() {
        withAnimation(.easeInOut) {
//            showLocationsList = !showLocationsList
            showLocationsList.toggle()
        }
    }
    
    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocationsList = false
        }
    }
    
    func nextButtonPressed() {
        // Get the current index
        guard let currentIndex = locations.firstIndex(where: { $0 == mapLocation }) else {
            print("Could not find current index in locations array! Should never happen.")
            return
        }
        
        // Check if the currentIndex is valid
        let nextIndex = currentIndex + 1
        guard locations.indices.contains(nextIndex) else {
            // Next index is NOT valid
            // Restart from 0
            guard let firstLocation = locations.first else { return }
            showNextLocation(location: firstLocation)
            return
        }
        
        // Next index IS valid
        let nextLocation = locations[nextIndex]
        showNextLocation(location: nextLocation)
    }
    
    // MARK: - CRUD helpers
    func startAdd(at coordinate: CLLocationCoordinate2D) {
        draftCoordinate = coordinate
        isPresentingForm = true
    }

    func finishAdd(location: Location) {
        locations.append(location)
        dataStore.save(locations)
        mapLocation = location
        isPresentingForm = false
        draftCoordinate = nil
    }

    func update(_ location: Location) {
        guard let idx = locations.firstIndex(of: location) else { return }
        locations[idx] = location
        dataStore.save(locations)
    }

    func delete(_ location: Location) {
        locations.removeAll { $0.id == location.id }
        dataStore.save(locations)
    }
    
}
