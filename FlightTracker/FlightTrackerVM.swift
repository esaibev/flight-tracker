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
    var camera: MapCameraPosition = .region(.startingRegion)
    var isFlightInfoVisible: Bool = false

    func getFlight(_ flightIata: String) async {
        do {
            let flight = try await FlightNetworkService.getFlight(flightIata)

            DispatchQueue.main.async {
                self.flight = flight
                if let lat = flight.lat, let lon = flight.lon {
                    let centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    withAnimation(.spring()) {
                        self.camera = MapCameraPosition.region(MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 400000, longitudinalMeters: 400000))
                    }
                }
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

extension CLLocationCoordinate2D {
    static var startingLocation: CLLocationCoordinate2D {
        return .init(latitude: 59.3293, longitude: 18.0686)
    }
}

extension MKCoordinateRegion {
    static var startingRegion: MKCoordinateRegion {
        return .init(center: .startingLocation,
                     latitudinalMeters: 400000,
                     longitudinalMeters: 400000)
    }
}
