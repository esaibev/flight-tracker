//
//  BriefFlightView.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-20.
//

import SwiftUI

struct BriefFlightView: View {
    @Environment(FlightTrackerVM.self) var ftvm
    @Environment(\.colorScheme) var colorScheme
    var flight: Flight?

    var body: some View {
        VStack(spacing: 4) {
            // Dark top bar
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 7) {
                        if let flightIata = self.flight?.flightIata {
                            Text("\(flightIata)")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundStyle(.main)
                        }

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
                    Text("\(self.flight?.airlineName ?? "Unknown Airline")")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    if let status = flight?.status {
                        Text("\(status.capitalizeFirstLetter())")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(ftvm.backgroundColor(for: status))
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
            .padding(.top, 2)
            .background(Color.dark)

            // Light part
            HStack(spacing: 4) {
                // Light part: left section
                VStack(spacing: 16) {
                    HStack(alignment: .center, spacing: 32) {
                        VStack(spacing: 3) {
                            Text("\(self.flight?.depIata ?? "N/A")")
                                .font(.system(size: 18))
                                .foregroundStyle(.black)
                            Text("\(self.flight?.depCity?.uppercased() ?? "N/A")")
                                .font(.system(size: 10))
                                .foregroundStyle(.black)
                        }

                        Image(systemName: "airplane")
                            .imageScale(.large)
                            .foregroundStyle(.main)

                        VStack(spacing: 3) {
                            Text("\(self.flight?.arrIata ?? "N/A")")
                                .font(.system(size: 18))
                                .foregroundStyle(.black)
                            Text("\(self.flight?.arrCity?.uppercased() ?? "N/A")")
                                .font(.system(size: 10))
                                .foregroundStyle(.black)
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
                        Group {
                            if let eta = flight?.eta {
                                let hours = eta / 60
                                let minutes = eta % 60

                                if eta == 0 {
                                    Text("Arriving in: N/A")
                                } else if hours == 0 {
                                    Text("Arriving in: \(minutes)m")
                                } else {
                                    Text("Arriving in: \(hours)h \(minutes)m")
                                }
                            } else {
                                Text("Arriving in: N/A")
                            }
                        }
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundStyle(.darkGrayText)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(10)
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
                                    Text("\(alt) m")
                                        .foregroundStyle(.black)
                                } else {
                                    Text("N/A")
                                        .foregroundStyle(.black)
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
                                        .foregroundStyle(.black)
                                } else {
                                    Text("N/A")
                                        .foregroundStyle(.black)
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
                                        .foregroundStyle(.black)
                                } else {
                                    Text("N/A")
                                        .foregroundStyle(.black)
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
                                            .foregroundStyle(.black)
                                    } else {
                                        Text("\(vSpeed, specifier: "%.1f") km/h")
                                            .foregroundStyle(.black)
                                    }
                                } else {
                                    Text("N/A")
                                }
                            }
                            .font(.system(size: 10))
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(10)
                .background(Color(red: 0.9176470588235294, green: 0.9176470588235294, blue: 0.9176470588235294))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 4)
        }
        .overlay {
            CustomDragIndicator()
                .frame(height: 171, alignment: .topLeading)
                .padding(.top, -22)
        }
    }
}

private struct CustomDragIndicator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .frame(width: 36, height: 5)
            .foregroundColor(Color(red: 0.5176470588235295, green: 0.5294117647058824, blue: 0.5607843137254902))
            .padding()
    }
}

#Preview {
    BriefFlightView(flight: Flight.sampleData)
        .environment(FlightTrackerVM())
        .preferredColorScheme(.light)
}
