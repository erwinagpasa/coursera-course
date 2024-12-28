//
//  BrightnessFilter.swift
//  
//
//  Created by Developer on 28/12/2024.
//

import Foundation

public struct BrightnessFilter: Filter {
    public let name = "Brightness"
    public var adjustment: Int // Range: -255 to 255

    public init(adjustment: Int) {
        self.adjustment = adjustment
    }

    public func apply(to image: RGBAImage) -> RGBAImage {
        var newImage = image

        for y in 0..<newImage.height {
            for x in 0..<newImage.width {
                if var pixel = newImage.getPixel(x: x, y: y) {
                    pixel.red = clamp(value: Int(pixel.red) + adjustment)
                    pixel.green = clamp(value: Int(pixel.green) + adjustment)
                    pixel.blue = clamp(value: Int(pixel.blue) + adjustment)
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
