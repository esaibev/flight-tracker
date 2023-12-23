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

@Observable
class FlightTrackerVM {
    var flight: Flight?
    var flights: [Flight] = []
    var errorMessage: String?
    var camera: MapCameraPosition = .region(.startingRegion)
    var bbox: (swLat: Double, swLon: Double, neLat: Double, neLon: Double) = (0, 0, 0, 0)
    var updateNr = 1
    var isFlightInfoVisible = false
    var annotationSelected = false

    @ObservationIgnored private var zoomLevel = 5.0
    @ObservationIgnored private var updateTimer: Timer?

    func calculateBbox(from region: MKCoordinateRegion) {
        let center = region.center
        let span = region.span

//        print("LatDelta: \(span.latitudeDelta)")
//        print("LonDelta: \(span.longitudeDelta)")

        // Calculate the zoom level
        zoomLevel = log2(360 / span.latitudeDelta)
//        print("Zoom Level: \(zoomLevel)")

        let swLat = center.latitude - (span.latitudeDelta / 2.0)
        let swLon = center.longitude - (span.longitudeDelta / 2.0)
        let neLat = center.latitude + (span.latitudeDelta / 2.0)
        let neLon = center.longitude + (span.longitudeDelta / 2.0)

        bbox = (swLat, swLon, neLat, neLon)
//        print(bbox)
    }

    func getFlights() async {
        do {
            let flights = try await FlightNetworkService.getFlights(bbox)
            DispatchQueue.main.async {
                self.flights = flights
                print(self.flights)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("Error getting flights: \(error.localizedDescription)")
                print("Detailed info: \(error)")
            }
        }
    }

    func getFlight(_ flightIata: String) async {
        do {
            let flight = try await FlightNetworkService.getFlight(flightIata)
            DispatchQueue.main.async {
                self.flight = flight
                self.isFlightInfoVisible = true
                self.annotationSelected = true
                self.startUpdateTimer()
                self.updateCameraPosition(for: flight)
            }
            print(flight)
        } catch {
            DispatchQueue.main.async {
                self.flight = nil
                self.errorMessage = error.localizedDescription
                print("Error getting flight: \(error.localizedDescription)")
                print("Detailed info: \(error)")
            }
        }
    }

    private func refreshFlightData() async {
        guard let flightIata = flight?.flightIata else { return }
        do {
            let flight = try await FlightNetworkService.getFlight(flightIata)
            DispatchQueue.main.async {
                self.flight = flight
            }
        } catch {
            DispatchQueue.main.async {
                self.flight = nil
                self.stopUpdateTimer()
                self.errorMessage = error.localizedDescription
                print("Error updating flight: \(error.localizedDescription)")
                print("Detailed info: \(error)")
            }
        }
    }

    func getCoordinates(for flight: Flight) -> CLLocationCoordinate2D {
        if flight.lat != nil && flight.lon != nil {
            return CLLocationCoordinate2D(latitude: (flight.lat)!, longitude: (flight.lon)!)
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    func getCoordinates() -> CLLocationCoordinate2D {
        if flight?.lat != nil && flight?.lon != nil {
            return CLLocationCoordinate2D(latitude: (flight?.lat)!, longitude: (flight?.lon)!)
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    func getAngle(for flight: Flight) -> Angle {
        guard let dir = flight.dir else { return Angle(degrees: 0) }
        return Angle(degrees: dir - 90)
    }

    func getAngle() -> Angle {
        guard let dir = flight?.dir else { return Angle(degrees: 0) }
        return Angle(degrees: dir - 90)
    }

    func startUpdateTimer() {
        stopUpdateTimer()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                print("Update \(self.updateNr)")
                self.updateNr += 1
                await self.refreshFlightData()
            }
        }
    }

    func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func updateCameraPosition(for flight: Flight) {
        let centerCoordinate: CLLocationCoordinate2D
        if let lat = flight.lat, let lon = flight.lon {
            centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            centerCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        withAnimation(.spring()) {
            self.camera = MapCameraPosition.region(MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 400000, longitudinalMeters: 400000))
        }
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
