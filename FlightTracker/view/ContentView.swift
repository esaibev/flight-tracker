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

    var body: some View {
        @Bindable var ftvm = ftvm

        Map(position: $ftvm.pos, interactionModes: [.zoom, .pan]) {
            if ftvm.flight != nil {
                Annotation("Flight " + (ftvm.flight?.flightIata ?? ""), coordinate: ftvm.getCoordinates()) {
                    Image(systemName: "airplane")
                        .font(.system(size: 24))
                        .foregroundStyle(.yellow)
                        .rotationEffect(ftvm.getAngle())
                        .shadow(color: Color(red: 0.0, green: 0.001, blue: 0.001, opacity: 0.5), radius: 1, x: 1, y: 2)
                }
//                .annotationTitles(.hidden)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                InputView()
            }
            .padding([.top, .horizontal])
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
            .background(.thinMaterial)
        }
    }
}

#Preview {
    ContentView()
        .environment(FlightTrackerVM())
}
