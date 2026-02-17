import Foundation
import AVFoundation
import Combine

protocol CameraManagerProtocol: ObservableObject {
    var session: AVCaptureSession { get }
    var recentSigns: [CapturedSign] { get }
    var detections: [DetectedObject] { get }
    var recentSignsPublisher: AnyPublisher<[CapturedSign], Never> { get }
    var objectDidChange: AnyPublisher<Void, Never> { get }
    func start()
    func stop()
}

