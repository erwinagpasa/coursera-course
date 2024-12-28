//
//  Filter.swift
//  
//
//  Created by Guillaume Denis on 30.10.2024.
//
import UIKit


// Filter class to apply the change on each pixel of the image
// open to be able to subclass and define custom filter in Playground

open class Filter {
    private var intensity: UInt8 // added
    private var transparency: UInt8 // added

    // %
    public init() {
        intensity = 100
        transparency = 255
    }
    
    public init(_ intensity: UInt8, _ transparency : UInt8) {
        self.intensity = intensity;
        self.transparency = transparency
    }
    
    public func filterImage(_ image: inout RGBAImage) {
        for i in 0 ..< (image.width * image.height) {
            modifyPixel(&image.pixels[i])
            applyIntensityChanges(on: &image.pixels[i])
            applyTransparencyChanges(on: &image.pixels[i])
        }
    }
    
//    public func apply(_ image: inout RGBAImage) {
//        for i in 0 ..< (image.width * image.height)-3 {
//            
//            
//            applyIntensityChanges(on: &image.pixels[i])
//            applyTransparencyChanges(on: &image.pixels[i])
//        }
//    }


    open func modifyPixel(_ pixel: inout Pixel) {
        // ...
        fatalError("this method must be overridden by a subclass")
    }
    
  
    
    open func applyIntensityChanges(on pixel: inout Pixel) {
        pixel.red = UInt8(max(0, min((Double(pixel.red) * Double(self.intensity) + 1.0) / 100.0, 255)))
        pixel.blue = UInt8(max(0, min((Double(pixel.blue) * Double(self.intensity) + 1.0) / 100.0, 255)))
        pixel.green = UInt8(max(0, min((Double(pixel.green) * Double(self.intensity) + 1.0) / 100.0, 255)))
    }
    
    open func applyTransparencyChanges(on pixel: inout Pixel) {
        pixel.alpha = max(0 ,min(UInt8(self.transparency), 255))
    }
    
    public func setIntensity(_ intensity: UInt8) {
        self.intensity = intensity
    }
    
    public func getIntensity() -> UInt8 {
        return intensity
    }
    
    public func setTransparency(_ transparency: UInt8) {
        self.transparency = transparency
    }
    
    public func getTransparency() -> UInt8 {
        return transparency
    }
}

// subclass to define diferent filter


/* Contrast filter.
The contrast filter adjusts the difference between light and dark areas.
Increasing contrast makes light pixels lighter and dark pixels darker,
while decreasing it brings the pixel values closer together.
newColor=((color−128)×factor)+128
*/

class ContrastFilter: Filter {
    private var factor: Double
    
    init(_ factor: Double = 1.0) {
        self.factor = factor
        super.init()
    }
    
    override func modifyPixel(_ pixel: inout Pixel) {
        if factor == 1 {
            return
        }
        pixel.red = UInt8(max(0, min(255, (Double(pixel.red) - 128.0) * factor + 128.0)))
        pixel.green =  UInt8(max(0, min(255, (Double(pixel.green) - 128.0) * factor + 128.0)))
        pixel.blue = UInt8(max(0, min(255, (Double(pixel.blue) - 128.0) * factor + 128.0)))
    }
    
}


// Negative filter.

 class NegativeFilter: Filter {
    override func modifyPixel(_ pixel: inout Pixel) {
        pixel.red = 255 - pixel.red
        pixel.green = 255 - pixel.green
        pixel.blue = 255 - pixel.blue
    }
}




/* Grey scale filter.
 Grayscale Filter
 The grayscale filter converts color to shades of gray by averaging the red, green, and blue channels to a single luminance value.
 Formula:
 gray = 0.3 * red + 0.59 * green + 011  * blue
*/
class GreyScaleFilter: Filter {
    override func modifyPixel(_ pixel: inout Pixel) {
        let grey = UInt8(0.3 * Double(pixel.red) + 0.59 * Double(pixel.green) + 0.11 * Double(pixel.blue))
        pixel.red = grey
        pixel.green = grey
        pixel.blue = grey
    }
}




/*
// Black and white filter.

Black and White Filter
The black and white filter makes each pixel either black or white,
depending on whether it’s above a certain brightness threshold.

 Formula:
 Convert the grayscale value;
 if the average of RGB values is greater than a threshold, make it white (255), otherwise black (0).
*/
class BlackAndWhiteFilter: GreyScaleFilter {
    var mid: UInt8
    
    init(_ factor: Double = 1.0) {
        // Adjust the mid-point by the given factor
        mid = UInt8(255 / 2 / factor)
        super.init()
    }
    
    override func modifyPixel(_ pixel: inout Pixel) {
        let gray = UInt8(0.3 * Double(pixel.red) + 0.59 * Double(pixel.green) + 0.11 * Double(pixel.blue))
        if (gray > mid) {
            pixel.red = 255
            pixel.green = 255
            pixel.blue = 255
        }
        else {
            pixel.red =  0
            pixel.green = 0
            pixel.blue = 0
        }
    }
}




/* Opacity (Alpha) Filter

 The opacity filter adjusts the transparency level of the image by setting the alpha value of each pixel.
*/

class OpacityFilter: Filter {
    var opacity: Double

    init(_ opacity: Double = 1.0) {
        self.opacity = max(0, min(1, opacity))
        super.init()
    }

    override func modifyPixel(_ pixel: inout Pixel) {
        pixel.alpha = UInt8(255 * opacity)
    }
}




// Brightness filter.
//
// Increase or decrease the intensity of each pixel in the image by the given
// factor. A factor less than 1 will darken the image and a factor greater
// than 1 will make it brighter.
class BrightnessFilter: Filter {
//    var intensity: Double  // 0 <- darker <- 1 -> brighter
//
//    init(_ intensity: Double = 1.0) {
//        self.intensity = intensity
//        super.init()
//    }
//    init(_ intensity: UInt8 = 100, transparancy : UInt8 = 100) {
//        super.init(intensity, transparancy)
//    }

    override func modifyPixel(_ pixel: inout Pixel) {
        return
      
        //        pixel.red = UInt8(max(0, min(255, Double(pixel.red) * getIntensity())))
        //        pixel.green = UInt8(max(0, min(255, Double(pixel.green) * getIntensity())))
        //        pixel.blue = UInt8(max(0, min(255, Double(pixel.blue) * getIntensity())))
        
        }
}

