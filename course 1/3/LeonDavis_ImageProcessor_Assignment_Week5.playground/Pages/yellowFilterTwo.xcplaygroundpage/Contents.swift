//: [Previous](@previous)

import Foundation

// Leon Davis
// iOS App Development | Week 5 | Assignment
// Image Processor using RGBAImage.swift
// 12 October 2023
// Copyright © 2023
//____________________________________________________

/*                  YELLOW FILTER SPLIT             */

import UIKit

// Load image file via UIImage:
var image = UIImage(named: "mixer.jpeg")!

//Store image into myRGBA:
var myRGBA: RGBAImage = RGBAImage(image: image)!

// Empty variables to store value total:

var totalRed = 0
var totalGreen = 0
var totalBlue = 0

// Calculate the total value of pixels for each colour chanel:

for y in 0..<myRGBA.height {
    for x in 0..<myRGBA.width{
        let index = y * myRGBA.width + x
        var pixel = myRGBA.pixels[index]
        totalRed   += Int(pixel.red)
        totalGreen += Int(pixel.green)
        totalBlue  += Int(pixel.blue)
    }
}

// Calculate avarage values for all 3 channels in image:

let count = myRGBA.width * myRGBA.height
var avgRed = totalRed/count
var avgGreen = totalGreen/count
var avgBlue = totalBlue/count

// Manipulate and Store new average values into new Variables:

var avgRedSum = avgRed + 3
var avgGreenSum = avgGreen + 3
var avgBlueSum = avgBlue + 3
//___________________________________________________

// image processing:
for y in 0..<myRGBA.height {
    for x in 100..<myRGBA.width{
        let index = y * myRGBA.width + x
        var pixel = myRGBA.pixels[index]
        let redDiff = Int(pixel.red) - avgRedSum
        if (redDiff>0) {
            pixel.blue = UInt8( max(0, min(255, avgRedSum, redDiff * 10)))
            myRGBA.pixels[index] = pixel
            myRGBA.toUIImage()!
        }
    }
}

//_________________________________

//image processed with Blue filter:

var newImage = myRGBA.toUIImage()!


// Original image file:
image
