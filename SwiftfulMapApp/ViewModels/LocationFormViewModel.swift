//
//  LocationFormViewModel.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import SwiftUI
import PhotosUI
import CoreLocation

@MainActor final class LocationFormViewModel: ObservableObject {

    // Campos editables
    var title: String
    var subtitle: String
    var description: String
    var link: String
    var coordinate: CLLocationCoordinate2D
    @Published var photos: [UIImage] = []

    @ObservationIgnored private let originalLocation: Location?
    @ObservationIgnored private let onSave: (Location, [UIImage]) -> Void
    
    var pickerItems: [PhotosPickerItem] = [] {
        didSet { loadImages() }
    }

    init(location: Location? = nil,
         coordinate: CLLocationCoordinate2D,
         onSave: @escaping (Location, [UIImage]) -> Void) {

        self.originalLocation = location
        self.title = location?.title ?? ""
        self.subtitle = location?.subtitle ?? ""
        self.description = location?.description ?? ""
        self.link = location?.link ?? ""
        self.coordinate = coordinate
        self.onSave = onSave
    }

    func save() {
        let names = (try? DiskPhotoStore.save(photos)) ?? []
        let loc = Location(
            id: originalLocation?.id ?? UUID(),
            title: title,
            subtitle: subtitle,
            description: description,
            coordinate: coordinate,
            updatedAt: .now,
            link: link,
            photos: names      // <- ya no strings vacíos
        )
        onSave(loc, photos)
    }
    
    private func loadImages() {
        // Capturamos los ítems en el actor principal y los pasamos
        let items = pickerItems
        
        Task.detached(priority: .userInitiated) {
            var buffer: [UIImage] = []
            
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    buffer.append(img)
                }
            }
            
            await MainActor.run { [weak self] in
                self?.photos.append(contentsOf: buffer)
            }
        }
    }
}
