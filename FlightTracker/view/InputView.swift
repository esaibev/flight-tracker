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
    @State private var isIconVisible = true
    @FocusState private var isInputActive: Bool

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.gray))
                TextField("Search by flight number", text: $searchText)
                    .focused($isInputActive)
                    .disableAutocorrection(true)
                    .foregroundColor(Color(.darkGray))
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
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Close") {
                                isInputActive = false
                            }
                        }
                    }
                    .onSubmit {
                        isInputActive = false
                        Task {
                            await ftvm.getFlight(searchText)
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
        }
    }
}

#Preview {
    InputView()
        .environment(FlightTrackerVM())
}
