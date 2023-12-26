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
    var selectedFlight: Flight?
    var flights: [Flight] = []
    var errorMessage: String?
    var camera: MapCameraPosition = .region(.startingRegion)
    var bbox: (swLat: Double, swLon: Double, neLat: Double, neLon: Double) = (0, 0, 0, 0)
    var updateNr = 1
    var annotationSelected = false

    @ObservationIgnored private var zoomLevel = 5
    @ObservationIgnored private var updateTimer: Timer?

    func calculateBbox(from region: MKCoordinateRegion) {
        let center = region.center
        let span = region.span

        // Calculate the zoom level
        zoomLevel = Int(log2(360 / span.latitudeDelta))
        if zoomLevel < 2 {
            zoomLevel = 0
        }

        let swLat = center.latitude - (span.latitudeDelta / 2.0)
        let swLon = center.longitude - (span.longitudeDelta / 2.0)
        let neLat = center.latitude + (span.latitudeDelta / 2.0)
        let neLon = center.longitude + (span.longitudeDelta / 2.0)

        bbox = (swLat, swLon, neLat, neLon)
//        print(bbox)
    }

    func getFlights() async {
        do {
            let flights = try await FlightNetworkService.getFlights(bbox, zoomLevel)

            DispatchQueue.main.async {
                if let selected = self.selectedFlight, !flights.contains(where: { $0.icao24 == selected.icao24 }) {
                    // Append selectedFlight to flights if it wasn't included in the fetch
                    self.flights = flights + [selected]
                } else {
                    self.flights = flights
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("Error getting flights: \(error.localizedDescription)")
                print("Detailed info: \(error)")
            }
        }
    }

    func getFlightInfo(_ flightIata: String) async {
        do {
            let flight = try await FlightNetworkService.getFlight(flightIata)
            DispatchQueue.main.async {
                self.selectedFlight = flight
            }
            print("Flight info: \(flight)")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("Error getting flight info: \(error.localizedDescription)")
                print("Detailed info: \(error)")
            }
        }
    }

    func getFlight(_ flightIata: String) async {
        do {
            let flight = try await FlightNetworkService.getFlight(flightIata)
            DispatchQueue.main.async {
                self.flights.append(flight)
                self.selectedFlight = flight
                self.annotationSelected = true
                self.updateCameraPosition(for: flight)
            }
//            print(flight)
        } catch {
            DispatchQueue.main.async {
                self.selectedFlight = nil
                self.errorMessage = error.localizedDescription
                print("Error getting flight: \(error.localizedDescription)")
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

    func getAngle(for flight: Flight) -> Angle {
        guard let dir = flight.dir else { return Angle(degrees: 0) }
        return Angle(degrees: dir - 90)
    }

    func startUpdateTimer() {
        stopUpdateTimer()
        Task {
            await self.getFlights()
        }
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                print("Update \(self.updateNr)")
                self.updateNr += 1
                await self.getFlights()
                if let flightIata = self.selectedFlight?.flightIata {
                    await self.getFlightInfo(flightIata)
                }
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
            self.camera = MapCameraPosition.region(MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 200000, longitudinalMeters: 200000))
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
