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
    var annotationSelected = false
    var isShowingBriefSheet = false
    var isShowingDetailedSheet = false

    @ObservationIgnored var bbox: (swLat: Double, swLon: Double, neLat: Double, neLon: Double) = (0, 0, 0, 0)
    @ObservationIgnored private var latestShownFlight: Flight?
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
    }

    func getFlights() async {
        do {
            let fetchedFlights = try await FlightNetworkService.getFlights(bbox, zoomLevel)

            DispatchQueue.main.async {
                var updatedFlights = fetchedFlights

                // Append selectedFlight to flights if it wasn't included in the fetch
                if let selected = self.selectedFlight, !updatedFlights.contains(where: { $0.icao24 == selected.icao24 }) {
                    updatedFlights.append(selected)
                }
                // Append latestShownFlight to flights to not make it disappear on map
                else if self.selectedFlight == nil,
                        let latestShown = self.latestShownFlight,
                        !updatedFlights.contains(where: { $0.icao24 == latestShown.icao24 })
                {
                    updatedFlights.append(latestShown)
                }

                self.flights = updatedFlights
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
                self.latestShownFlight = flight
            }
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
                self.latestShownFlight = flight
                self.isShowingBriefSheet = true
                self.selectedFlight = flight
                self.annotationSelected = true
                self.updateCameraPosition(for: flight)
            }
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
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                if !self.isShowingDetailedSheet {
                    await self.getFlights()
                }
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

    func backgroundColor(for status: String) -> Color {
        switch status {
        case "scheduled":
            return Color(.black)
        case "landed":
            return Color.blue
        default:
            return Color.greenBg
        }
    }

    func getFlagImage(for country: String, completion: @escaping (Image?) -> Void) {
        FlightNetworkService.getFlagImage(for: country, completion: completion)
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

extension String {
    func capitalizeFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
