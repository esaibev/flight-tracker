//
//  FlightNetworkService.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-18.
//

import Foundation

struct FlightNetworkService {
    static func getFlights(_ bbox: (swLat: Double, swLon: Double, neLat: Double, neLon: Double), _ zoomLevel: Int) async throws -> [Flight] {
//        return try getFlightsFromJSON()
        return try await getFlightsFromURL(bbox, zoomLevel)
    }

    private static func getFlightsFromURL(_ bbox: (swLat: Double, swLon: Double, neLat: Double, neLon: Double), _ zoomLevel: Int) async throws -> [Flight] {
        let urlString = "https://airlabs.co/api/v9/flights?api_key=8ba6bdb2-a617-455a-90aa-28510435a30d&bbox=\(bbox.swLat),\(bbox.swLon),\(bbox.neLat),\(bbox.neLon)&zoom=\(zoomLevel)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)

        // Debugging: Print raw JSON data
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON String: \(jsonString)\n")
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(FlightsResponse.self, from: data)
        return response.response
    }

    private static func getFlightsFromJSON() throws -> [Flight] {
        guard let path = Bundle.main.path(forResource: "flights-bbox-filter", ofType: "json") else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to find the JSON file"])
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        let flightsResponse = try decoder.decode(FlightsResponse.self, from: data)
        return flightsResponse.response
    }

    static func getFlight(_ flightIata: String) async throws -> Flight {
        // Get data from JSON to save API calls
//        return try getFlightFromJSON()

        // Standard way of getting data
        return try await getFlightFromURL(flightIata)
    }

    private static func getFlightFromURL(_ flightIata: String) async throws -> Flight {
        let urlString = "https://airlabs.co/api/v9/flight?api_key=8ba6bdb2-a617-455a-90aa-28510435a30d&flight_iata=\(flightIata)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)

        // Debugging: Print raw JSON data
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON String: \(jsonString)\n")
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(FlightResponse.self, from: data)
        return response.response
    }

    private static func getFlightFromJSON() throws -> Flight {
        guard let path = Bundle.main.path(forResource: "flight-iata-filter", ofType: "json") else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to find the JSON file"])
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path))

        // Print raw JSON data
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("JSON String: \(jsonString)")
//        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(FlightResponse.self, from: data)
        return response.response
    }
}

struct FlightsResponse: Codable {
    let response: [Flight]
}

struct FlightResponse: Codable {
    let response: Flight
}
