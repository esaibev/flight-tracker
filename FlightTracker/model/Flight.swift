//
//  FlightData.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-18.
//

import Foundation

struct Flight: Codable, Equatable {
    let aircraftIcao: String?
    let airlineIata: String?
    let airlineIcao: String?
    let flightIata: String?
    let flightIcao: String?
    let flightNumber: String?
    let depIata: String?
    let depName: String?
    let depCity: String?
    let arrIata: String?
    let arrName: String?
    let arrCity: String?
    let status: String?
    let duration: Int?
    let icao24: String?
    let lat: Double?
    let lon: Double?
    let alt: Int?
    let dir: Double?
    let speed: Int?
    let vSpeed: Double?
    let updated: Int?
    let built: Int?
    let eta: Int?

    enum CodingKeys: String, CodingKey {
        case aircraftIcao = "aircraft_icao"
        case airlineIata = "airline_iata"
        case airlineIcao = "airline_icao"
        case flightIata = "flight_iata"
        case flightIcao = "flight_icao"
        case flightNumber = "flight_number"
        case depIata = "dep_iata"
        case depName = "dep_name"
        case depCity = "dep_city"
        case arrIata = "arr_iata"
        case arrName = "arr_name"
        case arrCity = "arr_city"
        case status
        case duration
        case icao24 = "hex"
        case lat
        case lon = "lng"
        case alt
        case dir
        case speed
        case vSpeed = "v_speed"
        case updated
        case built
        case eta
    }
}
