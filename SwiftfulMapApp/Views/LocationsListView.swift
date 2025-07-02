//
//  LocationsListView.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//
//
//  LocationsListView.swift
//  SwiftfulMapApp
//
//  Created by Nick Sarno on 11/27/21.
//

import SwiftUI

struct LocationsListView: View {
    
    @Environment(LocationsViewModel.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.locations) { location in
                Button {
                    vm.showNextLocation(location: location)
                } label: {
                    listRowView(location: location)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct LocationsListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsListView()
            .environment(LocationsViewModel())
    }
}

extension LocationsListView {
    
    private func listRowView(location: Location) -> some View {
        HStack {
            if let imageName = location.photos.first {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading) {
                Text(location.title)
                    .font(.headline)
                Text(location.subtitle)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
}
