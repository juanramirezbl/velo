import SwiftUI
import AVFoundation

//  UIKit --> old, it is needed to show camera
//  SwiftUI --> new
//  UIViewRepresentable SwiftUI's protocol which content UIKit to show camera.
struct CameraPreview: UIViewRepresentable {
    
    let session: AVCaptureSession //data from CameraManager
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill //all screen
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {} //not used yet.
    
    class VideoPreviewView: UIView {
        //Use AVCaptureVideoPreviewLayer as layer for UI instead of a normal layer for UI to improve processing video
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer //force conversion to video
        }
    }
}
