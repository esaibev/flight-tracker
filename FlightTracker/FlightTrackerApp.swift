//
//  FlightTrackerApp.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-17.
//

import SwiftUI

@main
struct FlightTrackerApp: App {
    @State private var ftvm = FlightTrackerVM()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ftvm)
        }
    }
}
