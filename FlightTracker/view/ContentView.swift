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
    @Environment(\.scenePhase) var scenePhase
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
                            ftvm.annotationSelected = true
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
        .ignoresSafeArea(.all)
        .onMapCameraChange { context in
            let region = context.region
            ftvm.calculateBbox(from: region)
        }
        .overlay(alignment: .bottom, content: {
            if ftvm.isFlightInfoVisible {
                FlightInfoView(flight: ftvm.flight)
            } else {
                InputView()
            }
        })
        .onTapGesture {
            if !activeAnnotationTimer {
                if ftvm.annotationSelected {
                    ftvm.annotationSelected = false
                    selectedFlight = nil
                    ftvm.isFlightInfoVisible = false
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                print("Active scene")
                if ftvm.flight != nil {
                    ftvm.startUpdateTimer()
                }
            case .background:
                print("Background scene")
                ftvm.stopUpdateTimer()
            default:
                print("\(newPhase) scene")
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(FlightTrackerVM())
}
