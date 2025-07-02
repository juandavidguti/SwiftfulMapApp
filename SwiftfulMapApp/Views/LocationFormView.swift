//
//  LocationFormView.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import SwiftUI
import MapKit
import PhotosUI

struct LocationFormView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: LocationFormViewModel
    @State private var maxPhotos = 10
    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Información") {
                    TextField("Título", text: $vm.title)
                    TextField("Descripción", text: $vm.subtitle)
                }
                Section("Fotos") {
                    if #available(iOS 16.0, *) {
                        PhotosPicker(
                            selection: $vm.pickerItems,
                            maxSelectionCount: maxPhotos,
                            matching: .images) {
                                Label("Añadir fotos",
                                      systemImage: "photo.on.rectangle.angled")
                            }
                            .pickerStyle(.wheel)
                            .ignoresSafeArea(.keyboard)
                    }
                }
            }
            .navigationTitle("Lugar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        vm.save()
                        dismiss.callAsFunction()
                    }
                    .disabled(vm.title.isEmpty)
                }
            }
        }
    }
}
