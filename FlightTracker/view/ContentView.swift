//
//  ContentView.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-17.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @Environment(FlightTrackerVM.self) var ftvm
    @Environment(\.scenePhase) var scenePhase
    @State private var activeAnnotationTimer = false
    @State private var showDetailedView = false

    var body: some View {
        @Bindable var ftvm = ftvm

        GeometryReader { geometry in
            ZStack {
                Map(position: $ftvm.camera, interactionModes: [.zoom, .pan]) {
                    ForEach(ftvm.flights, id: \.icao24) { flight in
                        Annotation("", coordinate: ftvm.getCoordinates(for: flight)) {
                            CustomFlightAnnotationView(
                                isSelected: flight.icao24 == ftvm.selectedFlight?.icao24,
                                flight: flight,
                                rotationAngle: ftvm.getAngle(for: flight)
                            )
                            .onTapGesture {
                                ftvm.annotationSelected = true
                                activeAnnotationTimer = true
                                ftvm.selectedFlight = flight
                                ftvm.isShowingBriefSheet = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    activeAnnotationTimer = false
                                }
                                Task {
                                    guard let flightIata = flight.flightIata else { return }
                                    await ftvm.getFlightInfo(flightIata)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea(.all)
                .onMapCameraChange { context in
                    let region = context.region
                    ftvm.calculateBbox(from: region)
                    Task {
                        await ftvm.getFlights()
                    }
                }
                .onTapGesture {
                    if !activeAnnotationTimer {
                        if ftvm.annotationSelected {
                            ftvm.annotationSelected = false
                            ftvm.isShowingBriefSheet = false
                            ftvm.isShowingDetailedSheet = false
                            ftvm.selectedFlight = nil
                        }
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        print("Active scene")
                        ftvm.startUpdateTimer()
                    case .background:
                        print("Background scene")
                        ftvm.stopUpdateTimer()
                    default:
                        print("\(newPhase)".capitalizeFirstLetter(), "scene")
                    }
                }
                .overlay(alignment: .bottom, content: {
                    if ftvm.selectedFlight == nil {
                        InputView()
                    }
                })

                // Detailed Flight View
                if ftvm.isShowingDetailedSheet {
                    if let flight = ftvm.selectedFlight {
                        DetailedFlightView(flight: flight, showDetailedView: $showDetailedView)
                            .offset(y: showDetailedView ? 0 : geometry.size.height)
                            .onAppear {
                                withAnimation(.spring(duration: 0.3)) {
                                    showDetailedView = true
                                }
                            }
                    }
                }
            }
            .sheet(isPresented: $ftvm.isShowingBriefSheet) {
                Group {
                    if let flight = ftvm.selectedFlight {
                        BriefFlightView(flight: flight)
                            .gesture(DragGesture().onChanged { value in
                                if value.translation.height < -80 {
                                    ftvm.isShowingDetailedSheet = true
                                    ftvm.isShowingBriefSheet = false
                                }
                            })
                    }
                }
                .interactiveDismissDisabled()
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(171)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(171)))
                .presentationBackground(Color(red: 0.24705882352941178, green: 0.25882352941176473, blue: 0.2784313725490196, opacity: 0.75))
            }
        }
    }

    struct CustomFlightAnnotationView: View {
        var isSelected: Bool
        var flight: Flight
        var rotationAngle: Angle

        var body: some View {
            ZStack {
                if isSelected {
                    PulsatingEffectView()
                }
                Image(systemName: "airplane")
                    .padding(15)
                    .font(.system(size: 24))
                    .foregroundStyle(.main)
                    .rotationEffect(rotationAngle)
                    .shadow(color: Color(red: 0.0, green: 0.001, blue: 0.001, opacity: 0.5), radius: 1, x: 1, y: 2)
                    .scaleEffect(isSelected ? 1.3 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.15), value: isSelected)
            }
        }
    }

    struct PulsatingEffectView: View {
        @State private var animate = false

        var body: some View {
            Circle()
                .fill(Color.white.opacity(1))
                .frame(width: 24, height: 24)
                .scaleEffect(animate ? 2 : 1)
                .opacity(animate ? 0 : 1)
                .animation(.easeOut(duration: 1.7).repeatForever(autoreverses: false), value: animate)
                .onAppear {
                    self.animate = true
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(FlightTrackerVM())
}
