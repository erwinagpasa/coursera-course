import UIKit
import PlaygroundSupport

// MARK: - Pixel Struct

struct Pixel {
    var value: UInt32
    
    var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = (UInt32(newValue) & 0xFF) | (value & 0xFFFFFF00)
        }
    }
    
    var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
}

// MARK: - RGBAImage Struct

struct RGBAImage {
    var pixels: [Pixel]
    
    var width: Int
    var height: Int
    
    init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }
        
        // Ensure the image has the correct pixel format (RGBA)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * cgImage.width
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        // Allocate memory for pixel data
        guard let context = CGContext(data: nil,
                                      width: cgImage.width,
                                      height: cgImage.height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else { return nil }
        
        // Draw the image into the context to extract pixel data
        context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: cgImage.width, height: cgImage.height)))
        
        // Retrieve pixel data from the context
        guard let data = context.data else { return nil }
        let dataType = data.assumingMemoryBound(to: UInt32.self)
        
        // Initialize pixels array
        pixels = []
        pixels.reserveCapacity(cgImage.width * cgImage.height)
        
        for y in 0..<cgImage.height {
            for x in 0..<cgImage.width {
                let pixelIndex = y * cgImage.width + x
                let pixelValue = dataType[pixelIndex]
                let pixel = Pixel(value: pixelValue)
                pixels.append(pixel)
            }
        }
        
        width = cgImage.width
        height = cgImage.height
    }
    
    func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width
        
        // Allocate memory for pixel data
        let totalPixels = width * height
        var pixelData = [UInt32](repeating: 0, count: totalPixels)
        
        for i in 0..<pixels.count {
            pixelData[i] = pixels[i].value
        }
        
        // Create a CGContext with the pixel data
        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        // Create a CGImage from the context
        guard let cgImage = context.makeImage() else { return nil }
        
        // Convert CGImage to UIImage
        return UIImage(cgImage: cgImage)
    }
    
    func getPixel(x: Int, y: Int) -> Pixel? {
        guard x >= 0, x < width, y >= 0, y < height else { return nil }
        let index = y * width + x
        return pixels[index]
    }
    
    mutating func setPixel(x: Int, y: Int, pixel: Pixel) {
        guard x >= 0, x < width, y >= 0, y < height else { return }
        let index = y * width + x
        pixels[index] = pixel
    }
}

// MARK: - Filter Protocol

protocol Filter {
    var name: String { get }
    func apply(to image: RGBAImage) -> RGBAImage
}

// MARK: - BrightnessFilter Struct

struct BrightnessFilter: Filter {
    let name = "Brightness"
    var adjustment: Int // Range: -255 to 255

    init(adjustment: Int) {
        self.adjustment = adjustment
    }

    func apply(to image: RGBAImage) -> RGBAImage {
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

// MARK: - ContrastFilter Struct

struct ContrastFilter: Filter {
    let name = "Contrast"
    var adjustment: Double // Range: 0.0 to 2.0

    init(adjustment: Double) {
        self.adjustment = adjustment
    }

    func apply(to image: RGBAImage) -> RGBAImage {
        var newImage = image
        let factor = (259 * (adjustment * 255 + 255)) / (255 * (259 - adjustment * 255))

        for y in 0..<newImage.height {
            for x in 0..<newImage.width {
                if var pixel = newImage.getPixel(x: x, y: y) {
                    pixel.red = clamp(value: Int(Double(pixel.red) * factor - 128 * factor + 128))
                    pixel.green = clamp(value: Int(Double(pixel.green) * factor - 128 * factor + 128))
                    pixel.blue = clamp(value: Int(Double(pixel.blue) * factor - 128 * factor + 128))
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

// MARK: - SepiaFilter Struct

struct SepiaFilter: Filter {
    let name = "Sepia"

    init() {}

    func apply(to image: RGBAImage) -> RGBAImage {
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

    // Helper function to clamp values between 0 and 255
    private func clamp(value: Int) -> Int {
        return max(0, min(255, value))
    }
}

// MARK: - InvertFilter Struct

struct InvertFilter: Filter {
    let name = "Invert Colors"

    init() {}

    func apply(to image: RGBAImage) -> RGBAImage {
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

// MARK: - GrayscaleFilter Struct (Optional)

struct GrayscaleFilter: Filter {
    let name = "Grayscale"

    init() {}

    func apply(to image: RGBAImage) -> RGBAImage {
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

// MARK: - PredefinedFilters Struct

struct PredefinedFilters {
    static func filters() -> [String: Filter] {
        return [
            "Bright": BrightnessFilter(adjustment: 50),
            "Darken": BrightnessFilter(adjustment: -50),
            "High Contrast": ContrastFilter(adjustment: 1.8),
            "Low Contrast": ContrastFilter(adjustment: 0.5),
            "Sepia": SepiaFilter(),
            "Invert Colors": InvertFilter(),
            "Grayscale": GrayscaleFilter()
            // Add more predefined filters here as needed
        ]
    }
}

// MARK: - ImageProcessor Class

class ImageProcessor {
    private var filters: [Filter] = []
    private let predefinedFilters: [String: Filter] = PredefinedFilters.filters()

    // Method to add a filter to the pipeline
    func addFilter(_ filter: Filter) {
        filters.append(filter)
    }

    // Method to apply all filters in sequence
    func applyFilters(to image: RGBAImage) -> RGBAImage {
        var processedImage = image
        for filter in filters {
            processedImage = filter.apply(to: processedImage)
        }
        return processedImage
    }

    // Method to clear all filters
    func clearFilters() {
        filters.removeAll()
    }

    // Method to apply a predefined filter by name
    func applyPredefinedFilter(named name: String, to image: RGBAImage) -> RGBAImage? {
        guard let filter = predefinedFilters[name] else {
            print("Filter '\(name)' not found.")
            return nil
        }
        return filter.apply(to: image)
    }

    // Method to list all predefined filters
    func listPredefinedFilters() -> [String] {
        return Array(predefinedFilters.keys)
    }
}

// MARK: - Load and Display Original Image

guard let uiImage = UIImage(named: "sample.png") else {
    fatalError("Image 'sample.png' not found in Resources folder.")
}

// Display the original image in the live view
let originalImageView = UIImageView(image: uiImage)
originalImageView.contentMode = .scaleAspectFit
originalImageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
PlaygroundPage.current.liveView = originalImageView

// MARK: - Convert UIImage to RGBAImage

guard var rgbaImage = RGBAImage(image: uiImage) else {
    fatalError("Failed to create RGBAImage from UIImage.")
}

// MARK: - Initialize ImageProcessor

let processor = ImageProcessor()

// MARK: - List Available Predefined Filters

let availableFilters = processor.listPredefinedFilters()
print("Available Predefined Filters: \(availableFilters)")

// MARK: - Apply a Single Predefined Filter

let singleFilterName = "Sepia" // Change this to "Bright", "Darken", etc., to test other filters
if let filteredRGBAImage = processor.applyPredefinedFilter(named: singleFilterName, to: rgbaImage),
   let filteredUIImage = filteredRGBAImage.toUIImage() {
    let filteredImageView = UIImageView(image: filteredUIImage)
    filteredImageView.contentMode = .scaleAspectFit
    filteredImageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
    PlaygroundPage.current.liveView = filteredImageView
} else {
    print("Failed to apply filter: \(singleFilterName)")
}

// MARK: - Apply Multiple Filters in a Pipeline

processor.clearFilters() // Ensure no previous filters are applied
let brightnessFilter = BrightnessFilter(adjustment: 30) // Increase brightness by 30
let contrastFilter = ContrastFilter(adjustment: 1.5)     // Increase contrast by 50%
let invertFilter = InvertFilter()                        // Invert colors

processor.addFilter(brightnessFilter)
processor.addFilter(contrastFilter)
processor.addFilter(invertFilter)

let pipelineFilteredRGBAImage = processor.applyFilters(to: rgbaImage)

if let pipelineFilteredUIImage = pipelineFilteredRGBAImage.toUIImage() {
    let pipelineFilteredImageView = UIImageView(image: pipelineFilteredUIImage)
    pipelineFilteredImageView.contentMode = .scaleAspectFit
    pipelineFilteredImageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
    PlaygroundPage.current.liveView = pipelineFilteredImageView
} else {
    print("Failed to apply filter pipeline.")
}
