//
//  SwiftfulMapAppApp.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

//
//  SwiftfulMapAppApp.swift
//  SwiftfulMapApp
//
//  Created by Nick Sarno on 11/27/21.
//

import SwiftUI

@main
struct Memories: App {
    
    @StateObject private var vm = LocationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            LocationsView()
                .environmentObject(vm)
        }
    }
}
