//
//  InvertFilter.swift
//  
//
//  Created by Developer on 28/12/2024.
//

import Foundation

public struct InvertFilter: Filter {
    public let name = "Invert Colors"

    public init() {}

    public func apply(to image: RGBAImage) -> RGBAImage {
        var newImage = image

        for y in 0..<newImage.height {
            for x in 0..<newImage.width {
                if var pixel = newImage.getPixel(x: x, y: y) {
                    pixel.red = 255 - pixel.red
                    pixel.green = 255 - pixel.green
                    pixel.blue = 255 - pixel.blue
                    // Alpha remains unchanged
                    newImage.setPixel(x: x, y: y, pixel: pixel)
                }
            }
        }

        return newImage
    }
}
