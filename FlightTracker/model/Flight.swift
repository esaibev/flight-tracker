//
//  FlightData.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-18.
//

import Foundation

struct Flight: Codable, Equatable {
    let aircraftIcao: String?
    let airlineName: String?
    let flightIata: String?
    let flightIcao: String?
    let depIata: String?
    let depCity: String?
    let arrIata: String?
    let arrCity: String?
    let status: String?
    let arrDelayed: Int?
    let icao24: String?
    let regNr: String?
    let lat: Double?
    let lon: Double?
    let alt: Int?
    let dir: Double?
    let speed: Int?
    let vSpeed: Double?
    let built: Int?
    let percent: Double?
    let eta: Int?

    enum CodingKeys: String, CodingKey {
        case aircraftIcao = "aircraft_icao"
        case airlineName = "airline_name"
        case flightIata = "flight_iata"
        case flightIcao = "flight_icao"
        case depIata = "dep_iata"
        case depCity = "dep_city"
        case arrIata = "arr_iata"
        case arrCity = "arr_city"
        case status
        case arrDelayed = "arr_delayed"
        case icao24 = "hex"
        case regNr = "reg_number"
        case lat
        case lon = "lng"
        case alt
        case dir
        case speed
        case vSpeed = "v_speed"
        case built
        case percent
        case eta
    }
}
