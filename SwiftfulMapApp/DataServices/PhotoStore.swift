//
//  Untitled.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import UIKit

protocol PhotoStore {
    /// Persists the given UIImages and returns their filenames
    func save(images: [UIImage]) throws -> [String]
    /// Retrieves an image for the stored filename
    func image(named: String) -> UIImage?
}

final class DiskPhotoStore: PhotoStore {

    private let folder: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docs.appendingPathComponent("Images")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    func save(images: [UIImage]) throws -> [String] {
        try images.map { image in
            let file = folder.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                throw NSError(domain: "jpeg", code: 0)
            }
            try data.write(to: file, options: .atomic)
            return file.lastPathComponent
        }
    }
    
    func image(named name: String) -> UIImage? {
        let url = folder.appendingPathComponent(name)
        return UIImage(contentsOfFile: url.path)
    }
}

// MARK: - Static helpers -------------------------------------------------------

extension DiskPhotoStore {
    /// Persists images and returns filenames without exposing an instance.
    static func save(_ images: [UIImage]) throws -> [String] {
        try DiskPhotoStore().save(images: images)
    }
    
    /// Retrieves an image for the stored filename.
    static func image(for name: String) -> UIImage? {
        DiskPhotoStore().image(named: name)
    }
}
