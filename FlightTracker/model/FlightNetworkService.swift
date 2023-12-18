//
//  FlightNetworkService.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-18.
//

import Foundation

struct FlightNetworkService {
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

struct FlightResponse: Codable {
    let response: Flight
}
