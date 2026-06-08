import SwiftUI
import AVFoundation

/// Bridge that embeds the camera preview (UIKit) inside SwiftUI.
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    /// Creates the UIKit view that shows the session video full-screen.
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    /// No dynamic view update is required.
    func updateUIView(_ uiView: PreviewView, context: Context) {
    }
    
    /// UIKit view whose root layer is an `AVCaptureVideoPreviewLayer`.
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
}

