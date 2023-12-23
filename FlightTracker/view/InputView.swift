//
//  InputView.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-19.
//

import SwiftUI

struct InputView: View {
    @Environment(FlightTrackerVM.self) var ftvm
    @State var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var isIconVisible = true
    @State var showCancelButton = false
    @FocusState private var isInputActive: Bool

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.gray))

                TextField("", text: $searchText, prompt:
                    Text("Search by flight number").foregroundStyle(Color(white: 0.7)))
                    .focused($isInputActive)
                    .disableAutocorrection(true)
                    .keyboardType(.asciiCapable)
                    .foregroundColor(Color(.darkGray))
                    .textInputAutocapitalization(.characters)
                    .overlay(
                        Image(systemName: "xmark.circle.fill")
                            .padding()
                            .offset(x: 16)
                            .foregroundColor(Color(.darkGray))
                            .opacity(searchText.isEmpty ? 0 : 0.6)
                            .onTapGesture {
                                searchText = ""
                            },
                        alignment: .trailing
                    )
                    .onTapGesture {
                        isInputActive = true
                        showCancelButton = true
                    }
                    .onSubmit {
                        isInputActive = false
                        showCancelButton = false
                        Task {
                            await ftvm.getFlights()
//                            await ftvm.getFlight(searchText)
                        }
                    }
                    .submitLabel(.search)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                    .shadow(
                        color: .black.opacity(0.15),
                        radius: 7, x: 0, y: 4
                    )
            )

            if showCancelButton {
                Button("Cancel") {
                    isInputActive = false
                    showCancelButton = false
                }
                .foregroundStyle(colorScheme == .light ? .white : .blue)
            }
        }
        .padding()
        .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
        .background(Color(red: 0.24705882352941178, green: 0.25882352941176473, blue: 0.2784313725490196, opacity: 0.75))
    }
}

#Preview {
    InputView()
        .environment(FlightTrackerVM())
        .preferredColorScheme(.light)
}
