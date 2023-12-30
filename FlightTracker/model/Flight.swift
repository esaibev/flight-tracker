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
    let depName: String?
    let depCountry: String?
    let depTime: String?
    let depActual: String?
    let depActualTs: Double?
    let depTerminal: String?
    let depGate: String?
    let arrIata: String?
    let arrCity: String?
    let arrName: String?
    let arrCountry: String?
    let status: String?
    let arrTime: String?
    let arrEstimated: String?
    let arrDelayed: Int?
    let arrTerminal: String?
    let arrGate: String?
    let arrBaggage: String?
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
        case depName = "dep_name"
        case depCountry = "dep_country"
        case depTime = "dep_time"
        case depActual = "dep_actual"
        case depActualTs = "dep_actual_ts"
        case depTerminal = "dep_terminal"
        case depGate = "dep_gate"
        case arrIata = "arr_iata"
        case arrCity = "arr_city"
        case arrName = "arr_name"
        case arrCountry = "arr_country"
        case status
        case arrTime = "arr_time"
        case arrEstimated = "arr_estimated"
        case arrDelayed = "arr_delayed"
        case arrTerminal = "arr_terminal"
        case arrGate = "arr_gate"
        case arrBaggage = "arr_baggage"
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
