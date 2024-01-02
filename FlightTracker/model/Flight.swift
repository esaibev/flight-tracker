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
    let depActualUTC: String?
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
    let arrEstimatedUTC: String?
    let arrDelayed: Int?
    let arrTerminal: String?
    let arrGate: String?
    let arrBaggage: String?
    let icao24: String?
    let regNr: String?
    let regCountry: String?
    let lat: Double?
    let lon: Double?
    let alt: Int?
    let dir: Double?
    let speed: Int?
    let vSpeed: Double?
    let model: String?
    let engineType: String?
    let engineCount: String?
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
        case depActualUTC = "dep_actual_utc"
        case depTerminal = "dep_terminal"
        case depGate = "dep_gate"
        case arrIata = "arr_iata"
        case arrCity = "arr_city"
        case arrName = "arr_name"
        case arrCountry = "arr_country"
        case status
        case arrTime = "arr_time"
        case arrEstimated = "arr_estimated"
        case arrEstimatedUTC = "arr_estimated_utc"
        case arrDelayed = "arr_delayed"
        case arrTerminal = "arr_terminal"
        case arrGate = "arr_gate"
        case arrBaggage = "arr_baggage"
        case icao24 = "hex"
        case regNr = "reg_number"
        case regCountry = "flag"
        case lat
        case lon = "lng"
        case alt
        case dir
        case speed
        case vSpeed = "v_speed"
        case model
        case engineType = "engine"
        case engineCount = "engines"
        case built
        case percent
        case eta
    }

    static var sampleData: Flight {
        Flight(
            aircraftIcao: "B788",
            airlineName: "American Airlines",
            flightIata: "AA719",
            flightIcao: "AAL719",
            depIata: "FCO",
            depCity: "Rome",
            depName: "Leonardo da Vinci-Fiumicino Airport",
            depCountry: "IT",
            depTime: "2023-12-20 13:20",
            depActual: "2023-12-20 13:07",
            depActualUTC: "2023-12-20 12:07",
            depActualTs: 1703864109,
            depTerminal: "3",
            depGate: "E37",
            arrIata: "PHL",
            arrCity: "Arnavutköy, Istanbul",
            arrName: "Philadelphia International Airport",
            arrCountry: "US",
            status: "en-route",
            arrTime: "2023-12-20 17:05",
            arrEstimated: "2023-12-20 16:16",
            arrEstimatedUTC: "2023-12-20 21:16",
            arrDelayed: nil,
            arrTerminal: "A",
            arrGate: "22",
            arrBaggage: "CUST",
            icao24: "AC0196",
            regNr: "N873BB",
            regCountry: "US",
            lat: 43.34963,
            lon: 8.27349,
            alt: 10972,
            dir: 292,
            speed: 820,
            vSpeed: -0.3,
            model: "Boeing 787-8 pax",
            engineType: "jet",
            engineCount: "2",
            built: 2020,
            percent: 15,
            eta: 499
        )
    }
}
