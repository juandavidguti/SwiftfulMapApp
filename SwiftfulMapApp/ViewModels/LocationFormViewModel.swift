//
//  LocationFormViewModel.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import SwiftUI
import CoreLocation

final class LocationFormViewModel: ObservableObject {

    // Campos editables
    var title: String
    var subtitle: String
    var description: String
    var link: String
    var coordinate: CLLocationCoordinate2D
    var photos: [UIImage]

    @ObservationIgnored private let originalLocation: Location?
    @ObservationIgnored private let onSave: (Location) -> Void

    init(location: Location? = nil,
         coordinate: CLLocationCoordinate2D,
         onSave: @escaping (Location) -> Void) {

        self.originalLocation = location
        self.title = location?.title ?? ""
        self.subtitle = location?.subtitle ?? ""
        self.description = location?.description ?? ""
        self.link = location?.link ?? ""
        self.coordinate = coordinate
        self.photos = []
        self.onSave = onSave
    }

    func save() {
        let loc = Location(
            id: originalLocation?.id ?? UUID(),
            title: title,
            subtitle: subtitle,
            description: description,
            coordinate: coordinate,
            updatedAt: .now,
            link: link,
            photos: [] // Mapea fotos a nombres de archivo cuando añadas el PhotoStore
        )
        onSave(loc)
    }
}
