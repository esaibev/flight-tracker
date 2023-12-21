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
        VStack(spacing: 4) {
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
                                .background(.flightModelBg)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                        if self.flight?.regNr != nil {
                            Text("\(self.flight?.regNr ?? "")")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(.flightRegNrBg)
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
            HStack(spacing: 4) {
                // Light part: left section
                VStack(spacing: 16) {
                    HStack(alignment: .center, spacing: 32) {
                        VStack(spacing: 3) {
                            Text("\(self.flight?.depIata ?? "N/A")")
                                .font(.system(size: 18))
                            Text("\(self.flight?.depCity?.uppercased() ?? "N/A")")
                                .font(.system(size: 10))
                        }

                        Image(systemName: "airplane")
                            .imageScale(.large)
                            .foregroundStyle(.main)

                        VStack(spacing: 3) {
                            Text("\(self.flight?.arrIata ?? "N/A")")
                                .font(.system(size: 18))
                            Text("\(self.flight?.arrCity?.uppercased() ?? "N/A")")
                                .font(.system(size: 10))
                        }
                    }
                    // Timeline section
                    VStack(spacing: 4) {
                        if let percent = flight?.percent {
                            ProgressView(value: percent / 100.0)
                                .progressViewStyle(FlightProgressView())
                        } else {
                            ProgressView(value: 0)
                                .progressViewStyle(FlightProgressView())
                        }
                        Group {
                            if let eta = flight?.eta {
                                let hours = eta / 60
                                let minutes = eta % 60
                                if hours == 0 {
                                    Text("Arriving in: \(minutes)m")
                                } else {
                                    Text("Arriving in: \(hours)h \(minutes)m")
                                }
                            }
                        }
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundStyle(.darkGrayText)
                    }
                }
                .frame(minHeight: 72)
                .padding(10)
//                .background(.white)
                .background(Color(red: 0.9176470588235294, green: 0.9176470588235294, blue: 0.9176470588235294))
                .clipShape(RoundedRectangle(cornerRadius: 4))

                // Light part: right section
                HStack {
                    // First column
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Group {
                                Text("ALT.")
                                    .foregroundStyle(.darkGrayText)
                                if let alt = self.flight?.alt {
                                    Text("\(alt) km")
                                } else {
                                    Text("N/A")
                                }
                            }
                            .font(.system(size: 10))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Group {
                                Text("SPEED")
                                    .foregroundStyle(.darkGrayText)
                                if let speed = self.flight?.speed {
                                    Text("\(speed) km/h")
                                } else {
                                    Text("N/A")
                                }
                            }
                            .font(.system(size: 10))
                        }
                    }
                    // Second column
                    VStack(alignment: .trailing, spacing: 10) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Group {
                                Text("BUILT")
                                    .foregroundStyle(.darkGrayText)
                                if let built = self.flight?.built {
                                    Text(verbatim: "\(built)")
                                } else {
                                    Text("N/A")
                                }
                            }
                            .font(.system(size: 10))
                        }
                        VStack(alignment: .trailing, spacing: 4) {
                            Group {
                                Text("V.SPEED")
                                    .foregroundStyle(.darkGrayText)
                                if let vSpeed = self.flight?.vSpeed {
                                    if vSpeed == 0 {
                                        Text("\(vSpeed, specifier: "%.0f") km/h")
                                    } else {
                                        Text("\(vSpeed, specifier: "%.1f") km/h")
                                    }
                                } else {
                                    Text("N/A")
                                }
                            }
                            .font(.system(size: 10))
                        }
                    }
                }
                .frame(minHeight: 72)
                .padding(10)
//                .background(.white)
                .background(Color(red: 0.9176470588235294, green: 0.9176470588235294, blue: 0.9176470588235294))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .padding(.horizontal, 4)
        }
//        .frame(maxWidth: .infinity)
//        .background(Color(white: 1.0, opacity: 0.7))
        .background(Color(red: 0.24705882352941178, green: 0.25882352941176473, blue: 0.2784313725490196, opacity: 0.75))
//        .background(.thinMaterial)
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
    FlightInfoView(flight: Flight(aircraftIcao: "B788", airlineIata: "AA", airlineIcao: "AAL", airlineName: "American Airlines", flightIata: "AA719", flightIcao: "AAL719", depIata: "FCO", depCity: "Rome", arrIata: "PHL", arrCity: "Philadelphia", status: "en-route", duration: 585, arrDelayed: 32, icao24: "AC0196", regNr: "N873BB", lat: 43.34963, lon: 8.27349, alt: 10972, dir: 292, speed: 820, vSpeed: -0.3, built: 2020, percent: 15, eta: 499))
}
