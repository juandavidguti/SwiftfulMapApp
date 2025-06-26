//
//  LocationsView.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import SwiftUI
import MapKit

struct LocationsView: View {
    
    @Bindable var vm: LocationsViewModel
    
    var body: some View {
        ZStack {
            Map(position: $vm.mapRegion)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    LocationsView(vm: LocationsViewModel())
}
