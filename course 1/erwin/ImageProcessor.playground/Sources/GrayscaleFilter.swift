//
//  GrayscaleFilter.swift
//  
//
//  Created by Developer on 28/12/2024.
//

import Foundation

public struct GrayscaleFilter: Filter {
    public let name = "Grayscale"

    public init() {}

    public func apply(to image: RGBAImage) -> RGBAImage {
        var newImage = image

        for y in 0..<newImage.height {
            for x in 0..<newImage.width {
                if var pixel = newImage.getPixel(x: x, y: y) {
                    let gray = UInt8((UInt16(pixel.red) + UInt16(pixel.green) + UInt16(pixel.blue)) / 3)
                    pixel.red = gray
                    pixel.green = gray
                    pixel.blue = gray
                    newImage.setPixel(x: x, y: y, pixel: pixel)
                }
            }
        }

        return newImage
    }
}
