//
//  ImageProcessor.swift
//  
//
//  Created by Guillaume Denis on 30.10.2024.
//
import UIKit


// Class Image processor to apply different filter
//
// Apply a list of filters to a give image. There are a number of predefined
// filters that can be applied or new filters can be added and applied. Filters
// are applied in the order specified when calling `applyFilters`.

 public class ImageProcessor {
     var predefinedFilters: [String: Filter] = [
         // Predefined filters
         "Grey Scale": GreyScaleFilter(),
         "BlackAndWhite": BlackAndWhiteFilter(),
         "Negative": NegativeFilter(),
         "darker" : BrightnessFilter(30, 100),
         "brighter" : BrightnessFilter(15,233),
         "2x contrast" : ContrastFilter(2),
         "4x contrast" : ContrastFilter(44),
         "50% Opacity": OpacityFilter(53),
         "75% Opacity": OpacityFilter(75),
         "100% Opactity": OpacityFilter(1.0)
     ]
     
     public init() {
         
     }
              
     public func applyFilters(_ image: UIImage, filters: [String], customFilters : [Filter] = []) -> UIImage! {
     
        // Apply predefinied filter
        var rgbaImage = RGBAImage(image: image)!
        for name in filters {
            if let filter = self.predefinedFilters[name] {
                filter.filterImage(&rgbaImage)
            } else {
                print("Filter \"\(name)\" does not exist, nothing applied")
            }
        }
        for filter in customFilters {
             filter.filterImage(&rgbaImage)
         }
         return rgbaImage.toUIImage()
    }
}
