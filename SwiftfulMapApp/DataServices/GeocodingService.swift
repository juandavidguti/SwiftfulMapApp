//
//  GeocodingService.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import CoreLocation
import MapKit
@preconcurrency import Combine

protocol GeocodingService: Sendable {
    func placeInfo(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<PlaceInfo, Error>
}

struct PlaceInfo: Sendable {
    let name: String
    let subtitle: String   // locality + country, por ejemplo
    let description: String
    let link: String
}

/// Wrapper to allow capturing the Combine `promise` in `@Sendable` closures.
private struct PromiseBox: @unchecked Sendable {
    let call: (Result<PlaceInfo, Error>) -> Void
    init(_ call: @escaping (Result<PlaceInfo, Error>) -> Void) {
        self.call = call
    }
}

final class AppleGeocoder: GeocodingService {

    func placeInfo(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<PlaceInfo, Error> {
        let location = CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude)

        return Future { [coordinate] promise in
            let box = PromiseBox(promise)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let error {
                    box.call(.failure(error))
                    return
                }

                guard let pm = placemarks?.first else {
                    box.call(.failure(NSError(domain: "", code: 0)))
                    return
                }
                
                let name = pm.name ?? "Sin nombre"
                let subtitle = [pm.locality, pm.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")

                // Enriquecemos con MKLocalSearch (opcional)
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = name
                request.region = MKCoordinateRegion(center: coordinate,
                                                    span: .init(latitudeDelta: 0.02,
                                                                longitudeDelta: 0.02))
                
                MKLocalSearch(request: request).start { resp, _ in
                    let desc = resp?.mapItems.first?.pointOfInterestCategory?
                                    .rawValue
                                    .replacingOccurrences(of: "_", with: " ")
                                ?? ""
                    let link = resp?.mapItems.first?.url?.absoluteString ?? ""
                    box.call(.success(
                        PlaceInfo(name: name,
                                  subtitle: subtitle,
                                  description: desc,
                                  link: link)
                    ))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
