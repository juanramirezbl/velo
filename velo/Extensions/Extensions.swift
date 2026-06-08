import UIKit
import VideoToolbox

extension UIImage {
   /// Crops the image from a normalized Vision bounding box.
   /// Converts the normalized coordinates (bottom-left origin) to pixels
   /// (top-left origin) before cropping.
    func cropped(boundingBox: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        
        let x = boundingBox.minX * width
        
        // The Y axis is flipped because Vision uses the bottom-left corner as origin.
        let y = (1 - boundingBox.minY - boundingBox.height) * height
        let w = boundingBox.width * width
        let h = boundingBox.height * height
        
        let rect = CGRect(x: x, y: y, width: w, height: h)
        
        guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

extension CMSampleBuffer {
    /// Converts the video sample buffer into a `UIImage` with the given orientation.
    func toUIImage(orientation: UIImage.Orientation) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(self) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage,scale: 1.0,  orientation: orientation)
    }
}

