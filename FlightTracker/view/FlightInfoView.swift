//
//  FlightInfoView.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-20.
//

import SwiftUI

struct FlightInfoView: View {
    var flight: Flight?

    var body: some View {
        VStack {
            // Dark top bar
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 7) {
                        Text("\(self.flight?.flightIata ?? "")")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundStyle(.main)

                        if self.flight?.aircraftIcao != nil {
                            Text("\(self.flight?.aircraftIcao ?? "")")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(.grayBg)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                        if self.flight?.regNr != nil {
                            Text("\(self.flight?.regNr ?? "")")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(.redBg)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                    }
                    Text("\(self.flight?.airlineName ?? "")")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    if self.flight?.status != nil {
                        Text("\(self.flight?.status?.capitalizingFirstLetter() ?? "")")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.greenBg)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                    Group {
                        if let delay = flight?.arrDelayed, delay > 0 {
                            Text("Delayed \(delay) min")
                        } else {
                            Text("On time")
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                }
            }
            .padding()
            .background(Color.dark)

            // Light part
//            Text("Light section")
        }
//        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

#Preview {
    FlightInfoView(flight: Flight(aircraftIcao: "B788", airlineIata: "AA", airlineIcao: "AAL", airlineName: "American Airlines", flightIata: "AA719", flightIcao: "AAL719", depIata: "FCO", depCity: "Rome", arrIata: "PHL", arrCity: "Philadelphia", status: "en-route", duration: 585, arrDelayed: 32, icao24: "AC0196", regNr: "N873BB", lat: 43.34963, lon: 8.27349, alt: 10972, dir: 292, speed: 820, vSpeed: -0.3, built: 2020, eta: 499))
}
