//
//  SepiaFilter.swift
//  
//
//  Created by Developer on 28/12/2024.
//

import Foundation

public struct SepiaFilter: Filter {
    public let name = "Sepia"

    public init() {}

    public func apply(to image: RGBAImage) -> RGBAImage {
        var newImage = image

        for y in 0..<newImage.height {
            for x in 0..<newImage.width {
                if var pixel = newImage.getPixel(x: x, y: y) {
                    let red = clamp(value: Int(Double(pixel.red) * 0.393 + Double(pixel.green) * 0.769 + Double(pixel.blue) * 0.189))
                    let green = clamp(value: Int(Double(pixel.red) * 0.349 + Double(pixel.green) * 0.686 + Double(pixel.blue) * 0.168))
                    let blue = clamp(value: Int(Double(pixel.red) * 0.272 + Double(pixel.green) * 0.534 + Double(pixel.blue) * 0.131))

                    pixel.red = UInt8(red)
                    pixel.green = UInt8(green)
                    pixel.blue = UInt8(blue)

                    newImage.setPixel(x: x, y: y, pixel: pixel)
                }
            }
        }

        return newImage
    }


    private func clamp(value: Int) -> Int {
        return max(0, min(255, value))
    }
}
