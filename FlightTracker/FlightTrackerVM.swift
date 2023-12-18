//
//  FlightTrackerVM.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-17.
//

import Foundation
import MapKit
import Observation
import SwiftUI

extension CLLocationCoordinate2D {
    static let coordinates = CLLocationCoordinate2D(latitude: 58.072287, longitude: 15.299835)
}

@Observable
class FlightTrackerVM {
    var flight: Flight?
    var errorMessage: String?

    func getFlight(_ flightIata: String) async {
        do {
            let flight = try await FlightNetworkService.getFlight(flightIata)
            DispatchQueue.main.async {
                self.flight = flight
                print(flight)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("Error getting flight: \(error.localizedDescription)")
                print("Detailed info: \(error)")
            }
        }
    }

    static func defaultCamera() -> MapCamera {
        MapCamera(centerCoordinate: .coordinates,
                  distance: 400000,
                  heading: 0,
                  pitch: 0)
    }
}
