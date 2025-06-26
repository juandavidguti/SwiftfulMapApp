//
//  SwiftfulMapAppApp.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

import SwiftUI

@main
struct SwiftfulMapAppApp: App {
    
    @State private var vm = LocationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            LocationsView()
                .environment(vm)
        }
    }
}
