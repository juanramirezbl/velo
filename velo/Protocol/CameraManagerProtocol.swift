import Foundation
import AVFoundation
import Combine

/// Contract for the camera and real-time detection manager.
protocol CameraManagerProtocol: ObservableObject {
    /// Video capture session that feeds the preview.
    var session: AVCaptureSession { get }
    /// Most recent detected signs (recent thumbnails).
    var recentSigns: [CapturedSign] { get }
    /// Detections of the current frame, used to draw the boxes.
    var detections: [DetectedObject] { get }
    /// Publisher that emits when the recent signs change.
    var recentSignsPublisher: AnyPublisher<[CapturedSign], Never> { get }
    /// Publisher that re-emits the observable object's changes.
    var objectDidChange: AnyPublisher<Void, Never> { get }
    /// Starts capture and detection.
    func start()
    /// Stops capture and detection.
    func stop()
}
