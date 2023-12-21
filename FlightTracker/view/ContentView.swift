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
    @State private var annotationSelected = false
    @State private var activeAnnotationTimer = false
    @State private var selectedFlight: Flight?

    var body: some View {
        @Bindable var ftvm = ftvm

        Map(position: $ftvm.camera, interactionModes: [.zoom, .pan]) {
            if ftvm.flight != nil {
                Annotation("Flight " + (ftvm.flight?.flightIata ?? ""), coordinate: ftvm.getCoordinates()) {
                    Image(systemName: "airplane")
                        .padding(15)
                        .font(.system(size: 24))
                        .foregroundStyle(.main)
                        .rotationEffect(ftvm.getAngle())
                        .shadow(color: Color(red: 0.0, green: 0.001, blue: 0.001, opacity: 0.5), radius: 1, x: 1, y: 2)
                        .scaleEffect(ftvm.flight == selectedFlight ? 1.3 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.15), value: ftvm.flight == selectedFlight)
                        .onTapGesture {
                            annotationSelected = true
                            activeAnnotationTimer = true
                            ftvm.isFlightInfoVisible = true
                            selectedFlight = ftvm.flight
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                activeAnnotationTimer = false
                            }
                        }
                }
                .annotationTitles(.hidden)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if ftvm.isFlightInfoVisible {
                FlightInfoView(flight: ftvm.flight)
            } else {
                InputView()
            }
        }
        .onTapGesture {
            if !activeAnnotationTimer {
                if annotationSelected {
                    annotationSelected = false
                    selectedFlight = nil
                    ftvm.isFlightInfoVisible = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(FlightTrackerVM())
}
