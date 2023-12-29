//
//  DetailedFlightView.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-29.
//

import SwiftUI

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
                LazyVStack {
                    // First white box
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
                                    if let depActual = self.flight?.depActual {
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
                }
                .padding(4)
            }
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
        .background(Color.detailedFlightBg)
    }
}

#Preview {
    DetailedFlightView(flight: Flight(aircraftIcao: "B788", airlineName: "American Airlines", flightIata: "AA719", flightIcao: "AAL719", depIata: "FCO", depCity: "Rome", depActual: 1703855691, arrIata: "PHL", arrCity: "Philadelphia", status: "en-route", arrDelayed: 32, icao24: "AC0196", regNr: "N873BB", lat: 43.34963, lon: 8.27349, alt: 10972, dir: 292, speed: 820, vSpeed: -0.3, built: 2020, percent: 15, eta: 499), showDetailedView: .constant(true))
        .environment(FlightTrackerVM())
        .preferredColorScheme(.light)
}
