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
    @State private var pos: MapCameraPosition

    // Custom initializer
    init() {
        _pos = State(initialValue: .camera(FlightTrackerVM.defaultCamera()))
    }

    var body: some View {
        Map(position: $pos) {
            if (ftvm.flight != nil) {
                Annotation("Flight", coordinate: .coordinates) {
                    Image(systemName: "airplane")
                        .font(.system(size: 24))
                        .foregroundStyle(.yellow)
                    //                    .foregroundStyle(Color(red: 1.0, green: 0.4392156862745098, blue: 0.2627450980392157))
                        .rotationEffect(Angle(degrees: 174))
                        .shadow(color: Color(red: 0.0, green: 0.001, blue: 0.001, opacity: 0.5), radius: 1, x: 1, y: 2)
                    
                    //                                ZStack {
                    //                                    Circle()
                    //                                        .fill(.white)
                    //                                        .shadow(color: Color(red: 0.0, green: 0.001, blue: 0.001, opacity: 0.15), radius: 2, x: 1, y: 2)
                    //                                    Image(systemName: "airplane")
                    //                                        .foregroundColor(.green)
                    //                                        .padding(4)
                    //                                        .rotationEffect(Angle(degrees: 174))
                    //                                }
                }
                .annotationTitles(.hidden)                
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    Task {
                        await ftvm.getFlight("EI127")
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
                pos = .camera(MapCamera(centerCoordinate: newCenterCoordinate, distance: 400000, heading: 0, pitch: 0))
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(FlightTrackerVM())
}
