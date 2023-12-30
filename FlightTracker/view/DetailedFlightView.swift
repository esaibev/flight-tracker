//
//  DetailedFlightView.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-29.
//

import Foundation
import SwiftUI

struct BoxTitleStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 13))
            .fontWeight(.medium)
            .foregroundStyle(.grayText)
            .kerning(-0.3)
    }
}

extension View {
    func boxTitleStyle() -> some View {
        modifier(BoxTitleStyleModifier())
    }
}

struct DetailedFlightView: View {
    @Environment(FlightTrackerVM.self) var ftvm
    @Environment(\.colorScheme) var colorScheme

    var flight: Flight?
    @Binding var showDetailedView: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Dark sticky header
            HStack {
                // Dark sticky header: left section
                VStack(alignment: .leading) {
                    HStack(spacing: 7) {
                        if let flightIata = self.flight?.flightIata {
                            Text("\(flightIata)")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundStyle(.main)
                        }
                        
                        if let aircraftIcao = self.flight?.aircraftIcao {
                            Text("\(aircraftIcao)")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(.flightModelBg)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                        if let regNr = self.flight?.regNr {
                            Text("\(regNr)")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(.flightRegNrBg)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                        if let status = flight?.status {
                            Text("\(status.capitalizeFirstLetter())")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(ftvm.backgroundColor(for: status))
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                    }
                    Text("\(self.flight?.airlineName ?? "Unknown Airline")")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Dark sticky header: right section
                Button(action: {
                    self.showDetailedView = false
                    ftvm.isShowingDetailedSheet = false
                    ftvm.isShowingBriefSheet = true
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .imageScale(.large)
                }
            }
            .padding()
            .background(Color.dark)
            
            // ScrollView section
            ScrollView {
                LazyVStack(spacing: 4) {
                    // MARK: First white box
                    
                    VStack(spacing: 16) {
                        HStack(alignment: .center, spacing: 44) {
                            VStack(spacing: 3) {
                                Text("\(self.flight?.depIata ?? "N/A")")
                                    .font(.system(size: 26))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.black)
                                Text("\(self.flight?.depCity?.uppercased() ?? "N/A")")
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.darkGrayText)
                            }
                            
                            Image(systemName: "airplane")
                                .font(.system(size: 20))
                                .imageScale(.large)
                                .foregroundStyle(.main)
                            
                            VStack(spacing: 3) {
                                Text("\(self.flight?.arrIata ?? "N/A")")
                                    .font(.system(size: 26))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.black)
                                Text("\(self.flight?.arrCity?.uppercased() ?? "N/A")")
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.darkGrayText)
                            }
                        }
                        
                        // Timeline section
                        VStack(spacing: 4) {
                            if let percent = flight?.percent, percent > 0 {
                                if percent > 100 {
                                    ProgressView(value: 100)
                                        .progressViewStyle(FlightProgressView())
                                } else {
                                    ProgressView(value: percent / 100.0)
                                        .progressViewStyle(FlightProgressView())
                                }
                            } else {
                                ProgressView(value: 0)
                                    .progressViewStyle(FlightProgressView())
                            }
                            HStack {
                                Group {
                                    if let depActual = self.flight?.depActualTs {
                                        let currentTime = Date()
                                        let departureTime = Date(timeIntervalSince1970: depActual)
                                        
                                        let elapsed = currentTime.timeIntervalSince(departureTime)
                                        let hours = Int(elapsed / 3600)
                                        let minutes = Int((elapsed.truncatingRemainder(dividingBy: 3600)) / 60)
                                        
                                        if hours > 0 {
                                            Text("\(hours)h \(minutes)m ago")
                                        } else {
                                            Text("\(minutes)m ago")
                                        }
                                    } else {
                                        Text("N/A ago")
                                    }
                                    
                                    Spacer()
                                    
                                    if let eta = flight?.eta {
                                        let hours = eta / 60
                                        let minutes = eta % 60
                                        
                                        if eta == 0 {
                                            Text("N/A left")
                                        } else if hours == 0 {
                                            Text("\(minutes)m left")
                                        } else {
                                            Text("\(hours)h \(minutes)m left")
                                        }
                                    } else {
                                        Text("N/A left")
                                    }
                                }
                                .font(.system(size: 12))
                                .foregroundStyle(.darkGrayText)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    // MARK: Second white box section
                    
                    HStack(spacing: 4) {
                        // Left box
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DEPARTURE")
                                .boxTitleStyle()
                            
                            Text(formatTime(flight?.depActual))
                                .font(.system(size: 20))
                                .fontWeight(.medium)
                            
                            Text("Scheduled \(formatTime(flight?.depTime))")
                                .font(.system(size: 12))
                                .foregroundStyle(.darkGrayText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        // Right box
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ARRIVAL")
                                .boxTitleStyle()
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(arrivalCircleColor)
                                    .frame(width: 7)
                                
                                Text(formatTime(flight?.arrEstimated))
                                    .font(.system(size: 20))
                                    .fontWeight(.medium)
                            }
                            
                            Text("Scheduled \(formatTime(flight?.arrTime))")
                                .font(.system(size: 12))
                                .foregroundStyle(.darkGrayText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    // Airport info divider
                    SectionDivider(systemName: "bag", title: "AIRPORT INFO")
                    
                    // MARK: Third white box
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DEPARTURE")
                            .boxTitleStyle()
                        
                        Text("\(flight?.depName ?? "N/A")")
                            .font(.system(size: 16))
                        
                        HStack(spacing: 36) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Terminal")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.darkGrayText)
                                Text("\(flight?.depTerminal ?? "N/A")")
                                    .font(.system(size: 16))
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Gate")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.darkGrayText)
                                Text("\(flight?.depGate ?? "N/A")")
                                    .font(.system(size: 16))
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Country")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.darkGrayText)
                                
                                if let country = flight?.depCountry {
                                    AsyncImage(url: URL(string: "https://flagsapi.com/\(country)/flat/64.png")) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 20, height: 20)
                                        case .success(let image):
                                            image.resizable()
                                                .frame(width: 20, height: 20)
                                        case .failure:
                                            Text("\(country)")
                                                .font(.system(size: 16))
                                        @unknown default:
                                            Text("")
                                        }
                                    }
                                } else {
                                    Text("N/A")
                                        .font(.system(size: 16))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    // MARK: Fourth white box

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ARRIVAL")
                            .boxTitleStyle()
                        
                        Text("\(flight?.arrName ?? "N/A")")
                            .font(.system(size: 16))
                        
                        HStack(spacing: 36) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Terminal")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.darkGrayText)
                                Text("\(flight?.arrTerminal ?? "N/A")")
                                    .font(.system(size: 16))
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Gate")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.darkGrayText)
                                Text("\(flight?.arrGate ?? "N/A")")
                                    .font(.system(size: 16))
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Baggage")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.darkGrayText)
                                Text("\(flight?.arrBaggage ?? "N/A")")
                                    .font(.system(size: 16))
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Country")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.darkGrayText)
                                               
                                if let country = flight?.arrCountry {
                                    AsyncImage(url: URL(string: "https://flagsapi.com/\(country)/flat/64.png")) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 20, height: 20)
                                        case .success(let image):
                                            image.resizable()
                                                .frame(width: 20, height: 20)
                                        case .failure:
                                            Text("\(country)")
                                                .font(.system(size: 16))
                                        @unknown default:
                                            Text("")
                                        }
                                    }
                                } else {
                                    Text("N/A")
                                        .font(.system(size: 16))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(4)
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            .background(Color.detailedFlightBg)
        }
    }

    private struct SectionDivider: View {
        var systemName: String
        var title: String

        var body: some View {
            Group {
                HStack(spacing: 8) {
                    Image(systemName: systemName)
                        .font(.system(size: 20))
                        .foregroundStyle(.main)
                    Text(title)
                        .font(.system(size: 13))
                        .fontWeight(.medium)
                        .foregroundStyle(.darkGrayText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(.sectionBg)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
    }

    private func formatTime(_ dateString: String?) -> String {
        guard let dateString = dateString, !dateString.isEmpty else {
            return "N/A"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }

        return "N/A"
    }

    private var arrivalCircleColor: Color {
        if let arrDelayed = flight?.arrDelayed, arrDelayed > 0 {
            return .yellow
        }

        if flight?.arrEstimated == nil || flight?.arrTime == nil {
            return .greenBg
        }

        if let arrEstimatedString = flight?.arrEstimated,
           let arrTimeString = flight?.arrTime,
           let arrEstimatedDate = parseDate(arrEstimatedString),
           let arrTimeDate = parseDate(arrTimeString)
        {
            return arrEstimatedDate <= arrTimeDate ? .greenBg : .yellow
        }

        return .greenBg
    }

    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString, !dateString.isEmpty else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.date(from: dateString)
    }
}

#Preview {
//    DetailedFlightView(flight: Flight(aircraftIcao: "B788", airlineName: "American Airlines", flightIata: "AA719", flightIcao: "AAL719", depIata: "FCO", depCity: "Rome", depActualTs: 1703864109, arrIata: "PHL", arrCity: "Philadelphia", status: "scheduled", arrDelayed: 32, icao24: "AC0196", regNr: "N873BB", lat: 43.34963, lon: 8.27349, alt: 10972, dir: 292, speed: 820, vSpeed: -0.3, built: 2020, percent: 15, eta: 499), showDetailedView: .constant(true))
//        .environment(FlightTrackerVM())
//        .preferredColorScheme(.light)

//        DetailedFlightView(flight: Flight(aircraftIcao: "B788", airlineName: "American Airlines", flightIata: "AA719", flightIcao: "AAL719", depIata: "FCO", depCity: "Rome", depActual: "2023-12-28 11:30", depActualTs: 1703864109, arrIata: "PHL", arrCity: "Philadelphia", status: "scheduled", arrDelayed: 32, icao24: "AC0196", regNr: "N873BB", lat: 43.34963, lon: 8.27349, alt: 10972, dir: 292, speed: 820, vSpeed: -0.3, built: 2020, percent: 15, eta: 499), showDetailedView: .constant(true))
//            .environment(FlightTrackerVM())
//            .preferredColorScheme(.light)

//    DetailedFlightView(flight: Flight(aircraftIcao: "B788", airlineName: "American Airlines", flightIata: "AA719", flightIcao: "AAL719", depIata: "FCO", depCity: "Rome", depTime: "2023-12-20 13:20", depActual: "2023-12-20 13:07", depActualTs: 1703864109, arrIata: "PHL", arrCity: "Philadelphia", status: "scheduled", arrDelayed: nil, icao24: "AC0196", regNr: "N873BB", lat: 43.34963, lon: 8.27349, alt: 10972, dir: 292, speed: 820, vSpeed: -0.3, built: 2020, percent: 15, eta: 499), showDetailedView: .constant(true))
//        .environment(FlightTrackerVM())
//        .preferredColorScheme(.light)

//        DetailedFlightView(flight: Flight(aircraftIcao: "B788", airlineName: "American Airlines", flightIata: "AA719", flightIcao: "AAL719", depIata: "FCO", depCity: "Rome", depTime: "2023-12-20 13:20", depActual: "2023-12-20 13:07", depActualTs: 1703864109, arrIata: "PHL", arrCity: "Philadelphia", status: "scheduled", arrTime: "2023-12-20 17:05", arrDelayed: nil, icao24: "AC0196", regNr: "N873BB", lat: 43.34963, lon: 8.27349, alt: 10972, dir: 292, speed: 820, vSpeed: -0.3, built: 2020, percent: 15, eta: 499), showDetailedView: .constant(true))
//            .environment(FlightTrackerVM())
//            .preferredColorScheme(.light)

    DetailedFlightView(flight: Flight(aircraftIcao: "B788", airlineName: "American Airlines", flightIata: "AA719", flightIcao: "AAL719", depIata: "FCO", depCity: "Rome", depName: "Leonardo da Vinci-Fiumicino Airport", depCountry: "IT", depTime: "2023-12-20 13:20", depActual: "2023-12-20 13:07", depActualTs: 1703864109, depTerminal: "3", depGate: "E37", arrIata: "PHL", arrCity: "Philadelphia", arrName: "Philadelphia International Airport", arrCountry: "US", status: "en-route", arrTime: "2023-12-20 17:05", arrEstimated: "2023-12-20 16:16", arrDelayed: nil, arrTerminal: "A", arrGate: "22", arrBaggage: "CUST", icao24: "AC0196", regNr: "N873BB", lat: 43.34963, lon: 8.27349, alt: 10972, dir: 292, speed: 820, vSpeed: -0.3, built: 2020, percent: 15, eta: 499), showDetailedView: .constant(true))
        .environment(FlightTrackerVM())
        .preferredColorScheme(.light)
}
