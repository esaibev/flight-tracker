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
    @State private var isFlightInfoSelected: Bool = false
    @State private var annotationSelected = false
    @State private var activeAnnotationTimer = false

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
                        .onTapGesture {
//                            print("Annotation clicked")
                            annotationSelected = true
                            activeAnnotationTimer = true
                            ftvm.isFlightInfoVisible = true
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
//                    print("Map: Tap 1 registered")
                    annotationSelected = false
                    isFlightInfoSelected = false
                    ftvm.isFlightInfoVisible = false
                } else {
//                    print("Map: Tap 2 registered")
                }
            } else {
//                print("Map: Tap 3 registered")
            }
        }

//        .safeAreaInset(edge: .bottom) {
//            HStack {
//                InputView()
//            }
//            .padding([.top, .horizontal])
//            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
//            .background(.thinMaterial)
//        }
    }
}

#Preview {
    ContentView()
        .environment(FlightTrackerVM())
}
