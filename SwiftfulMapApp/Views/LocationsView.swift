//
//  LocationsView.swift
//  SwiftfulMapApp
//
//  Created by Juan David Gutierrez Olarte on 26/06/25.
//

//
//  LocationsView.swift
//  SwiftfulMapApp
//
//  Created by Nick Sarno on 11/27/21.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationsView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    let maxWidthForIpad: CGFloat = 700
    @State private var clManager = CLLocationManager()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            mapLayer
                .ignoresSafeArea()
                .onAppear { clManager.requestWhenInUseAuthorization() }
            
            VStack(spacing: 0) {
                header
                    .padding()
                    .frame(maxWidth: maxWidthForIpad)
                
                Spacer()
                locationsPreviewStack
            }
            
            // Floating Add (+) button
            Button(action: {
                vm.startAdd(at: vm.mapRegion.center)
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding([.trailing, .bottom], 24)
        }
        .sheet(item: $vm.sheetLocation, onDismiss: nil) { location in
            LocationDetailView(location: location)
        }
        .sheet(isPresented: $vm.isPresentingForm) {
            if let coord = vm.draftCoordinate {
                LocationFormView(
                    vm: LocationFormViewModel(
                        coordinate: coord,
                        onSave: vm.finishAdd(location:images:)
                    )
                )
            }
        }
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
            .environmentObject(LocationsViewModel())
    }
}

extension LocationsView {
    
    private var header: some View {
        VStack {
            Button(action: vm.toggleLocationsList) {
                Text(vm.mapLocation.title + (vm.mapLocation.subtitle.isEmpty ? "" : ", \(vm.mapLocation.subtitle)"))
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .animation(.none, value: vm.mapLocation)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .rotationEffect(Angle(degrees: vm.showLocationsList ? 180 : 0))
                    }
            }
            
            if vm.showLocationsList {
                LocationsListView()
            }
        }
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
    
    @available(iOS 17.0, *)
    private var mapLayer: some View {
        MapReader { proxy in
            Map(initialPosition: .region(vm.mapRegion)) {
                ForEach(vm.locations) { location in
                    Annotation("", coordinate: location.coordinate) {
                        LocationMapAnnotationView()
                            .scaleEffect(vm.mapLocation == location ? 1 : 0.7)
                            .shadow(radius: 10)
                            .onTapGesture {
                                vm.showNextLocation(location: location)
                            }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onMapCameraChange { ctx in
                vm.mapRegion = ctx.region
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.8)
                    .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                    .onEnded { value in
                        switch value {
                        case .second(true, let drag?):
                            let point = drag.location
                            if let coord = proxy.convert(point, from: .local) {
                                vm.startAdd(at: coord)
                            }
                        default:
                            break
                        }
                    }
            )
        }
    }
    
    private var locationsPreviewStack: some View {
        ZStack {
            ForEach(vm.locations) { location in
                if vm.mapLocation == location {
                    LocationPreviewView(location: location)
                        .shadow(color: Color.black.opacity(0.3), radius: 20)
                        .padding()
                        .frame(maxWidth: maxWidthForIpad)
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))
                }
            }
        }
    }
    
}
