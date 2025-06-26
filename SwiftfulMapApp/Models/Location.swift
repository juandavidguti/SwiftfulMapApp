//
//  Location.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

//
//  Location.swift
//  SwiftfulMapApp
//
//  Created by Nick Sarno on 11/27/21.
//

import Foundation
import CoreLocation

struct Location: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var subtitle: String
    var description: String
    var latitude: Double
    var longitude: Double
    var createdAt: Date
    var updatedAt: Date
    var link: String
    var photos: [String]           // file names stored in Documents/
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID = UUID(),
         title: String,
         subtitle: String,
         description: String,
         coordinate: CLLocationCoordinate2D,
         createdAt: Date = .now,
         updatedAt: Date = .now,
         link: String,
         photos: [String] = []) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.link = link
        self.photos = photos
    }
}
