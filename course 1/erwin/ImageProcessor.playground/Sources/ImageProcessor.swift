//
//  ImageProcessor.swift
//  
//
//  Created by Developer on 28/12/2024.
//

import Foundation

public class ImageProcessor {
    private var filters: [Filter] = []
    private let predefinedFilters: [String: Filter] = PredefinedFilters.filters()


    public func addFilter(_ filter: Filter) {
        filters.append(filter)
    }


    public func applyFilters(to image: RGBAImage) -> RGBAImage {
        var processedImage = image
        for filter in filters {
            processedImage = filter.apply(to: processedImage)
        }
        return processedImage
    }


    public func clearFilters() {
        filters.removeAll()
    }


    public func applyPredefinedFilter(named name: String, to image: RGBAImage) -> RGBAImage? {
        guard let filter = predefinedFilters[name] else {
            print("Filter '\(name)' not found.")
            return nil
        }
        return filter.apply(to: image)
    }


    public func listPredefinedFilters() -> [String] {
        return Array(predefinedFilters.keys)
    }
}


public struct PredefinedFilters {
    public static func filters() -> [String: Filter] {
        return [
            "Bright": BrightnessFilter(adjustment: 50),
            "Darken": BrightnessFilter(adjustment: -50),
            "High Contrast": ContrastFilter(adjustment: 1.8),
            "Low Contrast": ContrastFilter(adjustment: 0.5),
            "Sepia": SepiaFilter(),
            "Invert Colors": InvertFilter(),
            "Grayscale": GrayscaleFilter()
        ]
    }
}

