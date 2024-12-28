import UIKit

public struct Pixel {
    public var value: UInt32
    
    public var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = (UInt32(newValue) & 0xFF) | (value & 0xFFFFFF00)
        }
    }
    
    public var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    public var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    public var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
}

public struct RGBAImage {
    public var pixels: [Pixel]
    
    public var width: Int
    public var height: Int
    
    public init?(image: UIImage) {
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
    
    public func toUIImage() -> UIImage? {
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
    
    public func getPixel(x: Int, y: Int) -> Pixel? {
        guard x >= 0, x < width, y >= 0, y < height else { return nil }
        let index = y * width + x
        return pixels[index]
    }
    
    public mutating func setPixel(x: Int, y: Int, pixel: Pixel) {
        guard x >= 0, x < width, y >= 0, y < height else { return }
        let index = y * width + x
        pixels[index] = pixel
    }
}
