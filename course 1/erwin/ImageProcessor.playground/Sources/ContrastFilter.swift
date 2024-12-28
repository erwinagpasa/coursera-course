//
//  ContrastFilter.swift
//  
//
//  Created by Developer on 28/12/2024.
//

import Foundation

public struct ContrastFilter: Filter {
    public let name = "Contrast"
    public var adjustment: Double // Range: 0.0 to 2.0

    public init(adjustment: Double) {
        self.adjustment = adjustment
    }

    public func apply(to image: RGBAImage) -> RGBAImage {
        var newImage = image
        let factor = (259 * (adjustment * 255 + 255)) / (255 * (259 - adjustment * 255))

        for y in 0..<newImage.height {
            for x in 0..<newImage.width {
                if var pixel = newImage.getPixel(x: x, y: y) {
                    pixel.red = clamp(value: Int(Double(pixel.red) * factor - 128 * factor + 128))
                    pixel.green = clamp(value: Int(Double(pixel.green) * factor - 128 * factor + 128))
                    pixel.blue = clamp(value: Int(Double(pixel.blue) * factor - 128 * factor + 128))
                    newImage.setPixel(x: x, y: y, pixel: pixel)
                }
            }
        }

        return newImage
    }

    // Helper function to clamp values between 0 and 255
    private func clamp(value: Int) -> UInt8 {
        return UInt8(max(0, min(255, value)))
    }
}
