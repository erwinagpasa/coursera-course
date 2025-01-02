//
//  Filter.swift
//  Filterer
//
//  Created by Developer on 02/01/2025.
//

import UIKit
import CoreImage
import Foundation

public class Filter {
    
    public var imageReserve: UIImage
    
    public init(image: UIImage) {
        self.imageReserve = image
    }
    
    // MARK: - Saturation
    public func saturation(percent valuePercent: Int) -> UIImage {
        let scaleToComponent = Double(valuePercent) / 100.0
        
        guard let ciImage = CIImage(image: imageReserve) else {
            // If conversion fails, return original
            return imageReserve
        }
        
        let output = ciImage.applyingFilter("CIColorControls", parameters: [
            kCIInputSaturationKey: scaleToComponent
        ])
        
        return UIImage(ciImage: output)
    }
    
    // MARK: - Brightness
    public func brightness(percent valuePercent: Int) -> UIImage {
        // Using 0–100 => 0.0–1.0 scale
        let scaleToComponent = Double(valuePercent) / 100.0
        
        guard let ciImage = CIImage(image: imageReserve) else {
            return imageReserve
        }
        
        let output = ciImage.applyingFilter("CIColorControls", parameters: [
            kCIInputBrightnessKey: scaleToComponent
        ])
        
        return UIImage(ciImage: output)
    }
    
    // MARK: - Contrast
    public func contrast(percent valuePercent: Int) -> UIImage {
        let scaleToComponent = Double(valuePercent) / 100.0
        
        guard let ciImage = CIImage(image: imageReserve) else {
            return imageReserve
        }
        
        let output = ciImage.applyingFilter("CIColorControls", parameters: [
            kCIInputContrastKey: scaleToComponent
        ])
        
        return UIImage(ciImage: output)
    }
}
