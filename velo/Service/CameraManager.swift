import Foundation
import AVFoundation
import Vision
import UIKit
import Combine

/// Manager of the camera and the real-time detection pipeline.
///
/// Configures the capture session, runs the YOLO11n model on every frame with
/// Vision/CoreML, filters detections by confidence and, respecting a per-class
/// cooldown, triggers the alerts, the history and the persistence.
class CameraManager: NSObject, ObservableObject, CameraManagerProtocol {
    let session = AVCaptureSession()
    /// Dedicated queue to configure and start/stop the session without blocking the UI.
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")

    @Published var recentSigns: [CapturedSign] = []
    @Published var detections: [DetectedObject] = []

    private var visionRequests = [VNRequest]()
    /// Last alert time per sign class, used for the cooldown.
    private var lastDetectionTimes: [String: Date] = [:]
    private let speechService: SpeechServiceProtocol

    var recentSignsPublisher: AnyPublisher<[CapturedSign], Never> {
        $recentSigns.eraseToAnyPublisher()
    }

    var objectDidChange: AnyPublisher<Void, Never> {
        objectWillChange.map { _ in () }.eraseToAnyPublisher()
    }

    /// Creates the manager with the given speech service and prepares camera and model.
    init(speechService: SpeechServiceProtocol = SpeechService()) {
        self.speechService = speechService
        super.init()
        setupSession()
        setupVision()
    }

    /// Configures the capture session: rear-camera input and video output.
    private func setupSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .hd1920x1080

            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

            if self.session.canAddInput(videoInput) { self.session.addInput(videoInput) }

            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

            if self.session.canAddOutput(videoOutput) {
                self.session.addOutput(videoOutput)
                if let connection = videoOutput.connection(with: .video) {
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                }
            }
            self.session.commitConfiguration()
        }
    }

    /// Loads the CoreML model (YOLO11n) and prepares the Vision request.
    private func setupVision() {
        do {
            let config = MLModelConfiguration()
            let model = try VNCoreMLModel(for: best1(configuration: config).model)
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = .scaleFill
            self.visionRequests = [request]
        } catch {
            print("Error setupVision: \(error)")
        }
    }

    /// Processes the model results: filters by confidence, updates the boxes and,
    /// if the class cooldown has elapsed, triggers the alert, the crop and the history.
    private func processFrame(request: VNRequest, error: Error?, originalImage: UIImage) {
        DispatchQueue.main.async {
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                self.detections = []
                return
            }

            // Only detections with confidence above 90% are considered.
            let filteredResults = results.filter { $0.confidence > 0.90 }

            self.detections = filteredResults.map { obs in
                DetectedObject(
                    label: obs.labels.first?.identifier ?? "Unknown",
                    confidence: Double(obs.confidence),
                    rect: obs.boundingBox
                )
            }

            for observation in filteredResults {
                let label = observation.labels.first?.identifier ?? "Unknown"
                let lastTime = self.lastDetectionTimes[label] ?? Date.distantPast
                let timeElapsed = Date().timeIntervalSince(lastTime)

                // Avoid repeating the alert for the same class before 5 seconds.
                if timeElapsed > 5.0 {
                    if let croppedImage = originalImage.cropped(boundingBox: observation.boundingBox) {
                        self.addToHistory(image: croppedImage, label: label)
                        self.speechService.speak(label: label)
                        self.lastDetectionTimes[label] = Date()
                    }
                }
            }
        }
    }

    /// Adds a cropped sign to the recent history, keeping at most five.
    private func addToHistory(image: UIImage, label: String) {
        let newSign = CapturedSign(image: image, label: label, date: Date())
        recentSigns.insert(newSign, at: 0)
        if recentSigns.count > 5 {
            recentSigns.removeLast()
        }
    }

    /// Starts the capture session if it is not already running.
    func start() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    /// Stops the capture session if it is running.
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

/// Reception of the camera frames and dispatch of the inference.
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// Called for each captured frame: prepares the image and runs the model.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let currentImage = sampleBuffer.toUIImage(orientation: .up) else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)

        if let request = self.visionRequests.first as? VNCoreMLRequest {
            // The request is cloned to attach the callback with the current frame.
            let requestClone = VNCoreMLRequest(model: request.model) { [weak self] req, err in
                self?.processFrame(request: req, error: err, originalImage: currentImage)
            }
            requestClone.imageCropAndScaleOption = request.imageCropAndScaleOption
            try? handler.perform([requestClone])
        }
    }
}
