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
    @State private var depCountryFlag: Image? = nil
    @State private var arrCountryFlag: Image? = nil
    @State private var regCountryFlag: Image? = nil

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
                            
                            HStack(spacing: 4) {
                                Text(formatTime(flight?.depActual))
                                    .font(.system(size: 20))
                                    .fontWeight(.medium)
                                
                                Text(timezoneOffset(localTimeString: flight?.depActual, utcTimeString: flight?.depActualUTC))
                                    .font(.system(size: 12))
                                    .foregroundStyle(.darkGrayText)
                                    .fontWeight(.medium)
                            }
                            
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
                                
                                Text(timezoneOffset(localTimeString: flight?.arrEstimated, utcTimeString: flight?.arrEstimatedUTC))
                                    .font(.system(size: 12))
                                    .foregroundStyle(.darkGrayText)
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
                                
                                FlagImageView(image: depCountryFlag)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                
                                FlagImageView(image: arrCountryFlag)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    // Position info divider
                    SectionDivider(systemName: "mappin.and.ellipse", title: "POSITION INFO")
                    
                    // MARK: Fifth white section
                    
                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ALT")
                                .boxTitleStyle()
                            
                            Group {
                                if let alt = flight?.alt {
                                    Text("\(alt) ") + Text("m")
                                        .font(.system(size: 12))
                                        .foregroundColor(.darkGrayText)
                                } else {
                                    Text("N/A ") + Text("m")
                                        .font(.system(size: 12))
                                        .foregroundColor(.darkGrayText)
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LAT")
                                .boxTitleStyle()
                            
                            Group {
                                if let lat = flight?.lat {
                                    Text(String(format: "%.3f", locale: Locale(identifier: "en_US"), lat))
                                } else {
                                    Text("N/A")
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LON")
                                .boxTitleStyle()
                            
                            Group {
                                if let lon = flight?.lon {
                                    Text(String(format: "%.3f", locale: Locale(identifier: "en_US"), lon))
                                } else {
                                    Text("N/A")
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    // MARK: Sixth white section
                    
                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SPEED")
                                .boxTitleStyle()
                            
                            Group {
                                if let speed = flight?.speed {
                                    Text("\(speed) ") + Text("km/h")
                                        .font(.system(size: 12))
                                        .foregroundColor(.darkGrayText)
                                } else {
                                    Text("N/A ") + Text("km/h")
                                        .font(.system(size: 12))
                                        .foregroundColor(.darkGrayText)
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("V.SPEED")
                                .boxTitleStyle()
                            
                            Group {
                                if let vSpeed = self.flight?.vSpeed {
                                    if vSpeed == 0 {
                                        Text("\(vSpeed, specifier: "%.0f") ") + Text("km/h")
                                            .font(.system(size: 12))
                                            .foregroundColor(.darkGrayText)
                                    } else {
                                        Text("\(vSpeed, specifier: "%.1f") ") + Text("km/h")
                                            .font(.system(size: 12))
                                            .foregroundColor(.darkGrayText)
                                    }
                                } else {
                                    Text("N/A ") + Text("km/h")
                                        .font(.system(size: 12))
                                        .foregroundColor(.darkGrayText)
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("HEADING")
                                .boxTitleStyle()
                            
                            Group {
                                if let dir = flight?.dir {
                                    Text("\(dir, specifier: "%.0f")°")
                                } else {
                                    Text("N/A°")
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    // Aircraft info divider
                    SectionDivider(systemName: "airplane", title: "AIRCRAFT INFO")
                    
                    // MARK: Seventh white section
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MODEL")
                            .boxTitleStyle()
                        
                        Text("\(flight?.model ?? "N/A")")
                            .font(.system(size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    // MARK: Eighth white section
                    
                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("REG.NR")
                                .boxTitleStyle()
                            
                            Text("\(flight?.regNr ?? "N/A")")
                                .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("BUILT")
                                .boxTitleStyle()
                            
                            Group {
                                if let built = flight?.built {
                                    Text(verbatim: "\(built)")
                                } else {
                                    Text("N/A")
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("REG.ORIGIN")
                                .boxTitleStyle()
                            
                            FlagImageView(image: regCountryFlag)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    // MARK: Ninth white section
                    
                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ENGINE TYPE")
                                .boxTitleStyle()
                            
                            Group {
                                if let engineType = flight?.engineType {
                                    Text("\(engineType.capitalizeFirstLetter())")
                                } else {
                                    Text("N/A")
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ENGINES")
                                .boxTitleStyle()
                            
                            Text("\(flight?.engineCount ?? "N/A")")
                                .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ICAO24")
                                .boxTitleStyle()
                            
                            Text("\(flight?.icao24 ?? "N/A")")
                                .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(4)
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            .background(.detailedFlightBg)
        }
        .onAppear {
            getFlagImages()
        }
    }
    
    private func getFlagImages() {
        if let depCountry = flight?.depCountry {
            ftvm.getFlagImage(for: depCountry) { image in
                self.depCountryFlag = image
            }
        }
        
        if let arrCountry = flight?.arrCountry {
            ftvm.getFlagImage(for: arrCountry) { image in
                self.arrCountryFlag = image
            }
        }
        
        if let regCountry = flight?.regCountry {
            ftvm.getFlagImage(for: regCountry) { image in
                self.regCountryFlag = image
            }
        }
    }
    
    private struct FlagImageView: View {
        var image: Image?

        var body: some View {
            if let image = image {
                image.resizable().frame(width: 20, height: 20)
            } else {
                Text("N/A").font(.system(size: 16))
            }
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
        
    private func timezoneOffset(localTimeString: String?, utcTimeString: String?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            
        guard let localTimeStr = localTimeString,
              let utcTimeStr = utcTimeString,
              let localTime = dateFormatter.date(from: localTimeStr),
              let utcTime = dateFormatter.date(from: utcTimeStr)
        else {
            return "N/A"
        }

        let timeDifference = Calendar.current.dateComponents([.hour], from: utcTime, to: localTime).hour ?? 0
        if timeDifference > 0 {
            return "(UTC+\(timeDifference))"
        } else if timeDifference < 0 {
            return "(UTC\(timeDifference))"
        }
        return "(UTC)"
    }

    private var arrivalCircleColor: Color {
        if let arrDelayed = flight?.arrDelayed, arrDelayed > 0 {
            if arrDelayed >= 60 {
                return .red
            } else {
                return .yellow
            }
        }
            
        if let arrEstimatedString = flight?.arrEstimated,
           let arrTimeString = flight?.arrTime,
           let arrEstimatedDate = parseDate(arrEstimatedString),
           let arrTimeDate = parseDate(arrTimeString)
        {
            let difference = Calendar.current.dateComponents([.minute], from: arrTimeDate, to: arrEstimatedDate).minute ?? 0

            if difference >= 60 {
                // Return red if the estimated arrival time is 1 hour or more than the scheduled time
                return .red
            } else if difference <= 0 {
                // Return green if the estimated arrival time is earlier than or equal to the scheduled time
                return .greenBg
            } else {
                // Return yellow if the estimated arrival time is less than 1 hour late
                return .yellow
            }
        }

        // Return green if there's no delay or estimated time information
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
    DetailedFlightView(flight: Flight.sampleData, showDetailedView: .constant(true))
        .environment(FlightTrackerVM())
        .preferredColorScheme(.light)
}
