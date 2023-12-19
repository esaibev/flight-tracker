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

let defaultLocation = CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686)

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

    func getCoordinates() -> CLLocationCoordinate2D {
        if flight?.lat != nil && flight?.lon != nil {
            return CLLocationCoordinate2D(latitude: (flight?.lat)!, longitude: (flight?.lon)!)
        }
        return defaultLocation
    }

    func getAngle() -> Angle {
        guard let dir = flight?.dir else { return Angle(degrees: 0) }
        return Angle(degrees: dir - 90)
    }
}
