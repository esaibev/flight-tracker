//
//  FlightProgressView.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2023-12-21.
//

import SwiftUI

struct FlightProgressView: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(.progressViewBg)
                .frame(height: 3.0)
            ProgressView(configuration)
                .tint(.main)
                .frame(height: 3.0)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

#Preview {
    ProgressView(value: 0.4)
        .progressViewStyle(FlightProgressView())
        .previewLayout(.sizeThatFits)
}
