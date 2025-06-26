//
//  LocationsViewModel.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import Foundation
import MapKit
import SwiftUI

@Observable class LocationsViewModel {
    
    // ALL loaded locations
    var locations: [Location]
    
    // current location in map.
    var mapLocation: Location {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    
    var mapRegion: MapCameraPosition = .automatic
    
    @ObservationIgnored let mapSpan = MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1)
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
        if let initialLocation = locations.first {
            self.mapLocation = initialLocation
            updateMapRegion(location: initialLocation)
        } else {
            fatalError("No locations found in LocationsDataService.")
        }
    }
    
    private func updateMapRegion (location: Location) {
        withAnimation(.easeInOut){
            mapRegion = .camera(MapCamera(centerCoordinate: location.coordinates, distance: 1000))
        }
    }
}
