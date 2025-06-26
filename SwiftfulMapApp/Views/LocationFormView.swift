//
//  LocationFormView.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import SwiftUI
import MapKit

struct LocationFormView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: LocationFormViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Información") {
                    TextField("Título", text: $vm.title)
                    TextField("Descripción", text: $vm.subtitle)
                }
                // Aquí meterás un PhotosPicker más adelante
            }
            .navigationTitle("Lugar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        vm.save()
                        dismiss()
                    }
                    .disabled(vm.title.isEmpty)
                }
            }
        }
    }
}
