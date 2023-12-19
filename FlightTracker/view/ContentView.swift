//
//  ContentView.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-17.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @Environment(FlightTrackerVM.self) var ftvm
    @State private var pos: MapCameraPosition = .region(.userRegion)

    var body: some View {
        Map(position: $pos, interactionModes: [.zoom, .pan]) {
            if ftvm.flight != nil {
                Annotation("Flight", coordinate: ftvm.getCoordinates()) {
                    Image(systemName: "airplane")
                        .font(.system(size: 24))
                        .foregroundStyle(.yellow)
                        .rotationEffect(Angle(degrees: 174))
                        .shadow(color: Color(red: 0.0, green: 0.001, blue: 0.001, opacity: 0.5), radius: 1, x: 1, y: 2)
                }
                .annotationTitles(.hidden)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    Task {
                        await ftvm.getFlight("UA900")
                    }
                } label: {
                    Text("Get Flight")
                }
            }
            .padding(.top)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
            .background(.thinMaterial)
        }
        .onChange(of: ftvm.flight) {
            if let lat = ftvm.flight?.lat, let lon = ftvm.flight?.lon {
                let newCenterCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                pos = .camera(MapCamera(centerCoordinate: newCenterCoordinate, distance: 500000, heading: 0, pitch: 0))
            }
        }
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 59.3293, longitude: 18.0686)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,
                     latitudinalMeters: 100000,
                     longitudinalMeters: 100000)
    }
}

#Preview {
    ContentView()
        .environment(FlightTrackerVM())
}
