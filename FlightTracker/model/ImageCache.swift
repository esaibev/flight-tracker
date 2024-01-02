//
//  ImageCache.swift
//  FlightTracker
//
//  Created by Esaias Bevegård on 2024-01-02.
//

import Foundation
import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private var cache = [String: Image]()

    func image(for key: String) -> Image? {
        return cache[key]
    }

    func setImage(_ img: Image, for key: String) {
        cache[key] = img
    }
}
