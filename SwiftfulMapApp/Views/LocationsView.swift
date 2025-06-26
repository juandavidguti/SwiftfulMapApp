//
//  LocationsView.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import SwiftUI

struct LocationsView: View {
    
    @Environment(LocationsViewModel.self) var vm
    
    var body: some View {
        List {
            ForEach(vm.locations) {
                Text($0.name)
            }
        }
    }
}

#Preview {
    LocationsView()
        .environment(LocationsViewModel())
}
