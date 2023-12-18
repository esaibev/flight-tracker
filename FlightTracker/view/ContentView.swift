//
//  ContentView.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-17.
//

import SwiftUI

struct ContentView: View {
    @Environment(FlightTrackerVM.self) var ftvm

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button {
                Task {
                    await ftvm.getFlight("EI127")
                }
            } label: {
                Text("Get Flight")
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(FlightTrackerVM())
}
