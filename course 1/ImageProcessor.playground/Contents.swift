//: Playground - Guillaume Image processor

// Usage
// =====
//
// Class Filter define the classe to modify the image and some predifined filter
// Class ImageProcessor embbed a dictionary of predefined filters and method to apply filters
// var imageProcessor = ImageProcessor()
// var newImage = imageProcessor.applyFilters(image, ["predefined Filter 1", ...])
// for custome filter you have declare a subclass of Filter and add it in the last paremeter of method applyFilters


import UIKit

var image = UIImage(named: "sample")!


// --- Processing image

var imageProcessor = ImageProcessor()



// --- apply 1 filter

let negResult = imageProcessor.applyFilters(image, filters: ["Negative"])
let blackWhiteResult = imageProcessor.applyFilters(image, filters: ["BlackAndWhite"])
let brightResult = imageProcessor.applyFilters(image, filters: ["brighter"])


// --- apply multiple filter

let multipleResult = imageProcessor.applyFilters(image, filters: ["brighter", "Grey Scale"])
let otherMultipleResult = imageProcessor.applyFilters(image, filters: ["75% Opacity","2x contrast"])


// --- custom filter

class Red0Filter: Filter {
    override func modifyPixel(_ pixel: inout Pixel) {
        pixel.red = 0
    }
}

class green0Filter: Filter {
    override func modifyPixel(_ pixel: inout Pixel) {
        pixel.green = 50
        pixel.blue = 120

    }
}


// Apply Multiple filter

let myFilterRed = Red0Filter()
var myFilterGreen = green0Filter()

let blueResult = imageProcessor.applyFilters(image, filters: [], customFilters: [myFilterRed, myFilterGreen])
let greenFilterApplied = imageProcessor.applyFilters(image, filters: [], customFilters: [myFilterGreen])
let greenFilterAppliedwithLessIntensity = imageProcessor.applyFilters(image, filters: [], customFilters: [myFilterGreen])



// apply custom filter and modify Intensity transparency


var aCustomFilter = green0Filter()
var imageMutable = UIImage(named: "sample")!

let result1 = imageProcessor.applyFilters(imageMutable, filters: [], customFilters: [aCustomFilter])


// modify existing filter --  change intensity
aCustomFilter.setIntensity(20)
var imageMutable2 = UIImage(named: "sample")!

let result2 = imageProcessor.applyFilters(imageMutable2, filters: [], customFilters: [aCustomFilter])

// change transparency
aCustomFilter.setTransparency(70)
var imageMutable3 = UIImage(named: "sample")!

let notherResult3 = imageProcessor.applyFilters(imageMutable3, filters: [], customFilters: [aCustomFilter])


// change transparency
aCustomFilter.setTransparency(150)
aCustomFilter.setIntensity(80 )
var imageMutable4 = UIImage(named: "sample")!

let notherResult4 = imageProcessor.applyFilters(imageMutable4, filters: [], customFilters: [aCustomFilter])
