import Foundation
import AVFoundation
import Combine

protocol CameraManagerProtocol: ObservableObject {
    var session: AVCaptureSession { get }
    var recentSigns: [CapturedSign] { get }
    var detections: [DetectedObject] { get }
    func start()
    func stop()
}

