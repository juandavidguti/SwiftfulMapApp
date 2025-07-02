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

@MainActor @Observable class LocationsViewModel {
    
    // All loaded locations
    private(set) var locations: [Location] = []
    private var cancellables = Set<AnyCancellable>()
    private let dataStore: LocationDataStore
    private let photoStore: PhotoStore
    private let geocoder: GeocodingService
    var isPresentingForm: Bool = false
    var draftCoordinate: CLLocationCoordinate2D?
    var draftPlaceInfo: PlaceInfo?
    var editingLocation: Location? // pin to edit
    
    // Current location on map
    var mapLocation: Location {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    
    // Current region on map
    var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    // Show list of locations
    var showLocationsList: Bool = false
    
    // Show location detail via sheet
    var sheetLocation: Location? = nil
    
    init(dataStore: LocationDataStore = JSONLocationDataStore(),geocoder: GeocodingService = AppleGeocoder(),
         photoStore: PhotoStore = DiskPhotoStore()) {
        self.dataStore = dataStore
        self.geocoder = geocoder
        self.photoStore = photoStore
        // Cargamos primero en una variable local para no acceder a `self`
        let stored = dataStore.fetchLocations()
        self.locations = stored

        if let first = stored.first {
            self.mapLocation = first
        }
        else {
            let placeholder = Location.placeholder          // ← único punto de verdad
            self.locations = [placeholder]
            self.mapLocation = placeholder
            self.mapRegion = MKCoordinateRegion(
                center: placeholder.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            )
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
            updateMapRegion(location: location)   // ← fuerza el recentrado
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
        geocoder.placeInfo(for: coordinate)
            .sink(receiveCompletion: { _ in }) { [weak self] info in
                guard let self else { return }
                self.draftCoordinate = coordinate
                self.draftPlaceInfo  = info
                self.isPresentingForm = true
            }
            .store(in: &cancellables)
    }

    func finishAdd(location: Location, images: [UIImage]) {
        let paths = try? photoStore.save(images: images)
        var loc = location
        loc.photos = paths ?? []
        locations.append(loc)
        dataStore.save(locations)
        mapLocation = location
        isPresentingForm = false
        draftCoordinate = nil
    }


    /// Manda el formulario en modo edición
    func startEdit(_ location: Location) {
        editingLocation = location
    }
    /// Borra el pin y actualiza estado
    func delete(location: Location) {
        locations.removeAll { $0.id == location.id }
        if mapLocation == location {
            mapLocation = locations.first ?? Location.placeholder
        }
        sheetLocation = nil
    }
    
    /// Guarda la edición y cierra el formulario
    func update(location newValue: Location, images: [UIImage]) {
        if let idx = locations.firstIndex(where: { $0.id == newValue.id }) {
            locations[idx] = newValue               // (o persiste fotos antes si quieres)
            mapLocation = newValue
        }
        editingLocation = nil                       // cierra la hoja
    }
    
}
