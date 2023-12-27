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

    var body: some View {
        @Bindable var ftvm = ftvm

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
        }
        .onTapGesture {
            if !activeAnnotationTimer {
                if ftvm.annotationSelected {
                    ftvm.annotationSelected = false
                    ftvm.isShowingBriefSheet = false
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
                print("\(newPhase) scene")
            }
        }
        .overlay(alignment: .bottom, content: {
            if ftvm.selectedFlight != nil {
                FlightInfoView(flight: ftvm.selectedFlight)
                    .gesture(DragGesture()
                        .onChanged { value in
                            // Check if the drag is upward and exceeds a threshold
                            if value.translation.height < -80 { // threshold
                                ftvm.isShowingDetailedSheet = true
                                ftvm.isShowingBriefSheet = false
                            }
                        }
                    )
            } else {
                InputView()
            }
        })
//        .overlay(alignment: .bottom, content: {
        ////            InputView()
//            if ftvm.selectedFlight == nil {
//                InputView()
//            }
//        })
//        .sheet(isPresented: $ftvm.isShowingBriefSheet, onDismiss: {
//            ftvm.selectedFlight = nil
//            ftvm.annotationSelected = false
//        }) {
//            ZStack {
//                if let flight = ftvm.selectedFlight {
//                    FlightInfoView(flight: flight)
//                        .gesture(DragGesture()
//                            .onChanged { value in
//                                print("Value: \(value.translation.height)")
//                                // Check if the drag is upward and exceeds a threshold
//                                if value.translation.height < -100 { // threshold
//                                    ftvm.isShowingDetailedSheet = true
//                                    ftvm.isShowingBriefSheet = false
//                                }
//                            }
//                        )
//                }
//            }
//            .ignoresSafeArea()
        ////            .highPriorityGesture(DragGesture(minimumDistance: 0, coordinateSpace: .local))
        ////            .interactiveDismissDisabled()
        ////            .background(Color(red: 0.24705882352941178, green: 0.25882352941176473, blue: 0.2784313725490196, opacity: 0.75))
//            .presentationBackground(Color(red: 0.24705882352941178, green: 0.25882352941176473, blue: 0.2784313725490196, opacity: 0.75))
//            .presentationDetents([.height(169)])
//            .presentationBackgroundInteraction(.enabled(upThrough: .height(169)))
//        }
        .fullScreenCover(isPresented: $ftvm.isShowingDetailedSheet, content: {
            AnotherView()
        })
//        .sheet(isPresented: $ftvm.isShowingDetailedSheet, onDismiss: {
//            ftvm.isShowingDetailedSheet = false
//            ftvm.isShowingBriefSheet = true
//            ftvm.annotationSelected = false
//        }) {
//            Text("Detailed Sheet Content")
//        }
    }

    struct AnotherView: View {
        @Environment(\.presentationMode) var presentationMode

        var body: some View {
            VStack {
                HStack {
                    Button("Cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    }.padding()

                    Spacer()
                }
                Spacer()
                Text("Second View")
                    .bold()
                    .font(.largeTitle)
                Spacer()
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
