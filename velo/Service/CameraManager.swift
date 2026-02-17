import Foundation
import AVFoundation
import Vision
import UIKit
import Combine

class CameraManager: NSObject, ObservableObject, CameraManagerProtocol {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    
    @Published var recentSigns: [CapturedSign] = []
    @Published var detections: [DetectedObject] = []
    
    private var visionRequests = [VNRequest]()
    private var lastDetectionTimes: [String: Date] = [:]
    private let speechService: SpeechServiceProtocol  
    
    init(speechService: SpeechServiceProtocol = SpeechService()) {
        self.speechService = speechService
        super.init()
        setupSession()
        setupVision()
    }
    
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
    
    private func processFrame(request: VNRequest, error: Error?, originalImage: UIImage) {
        DispatchQueue.main.async {
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                self.detections = []
                return
            }
            
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
    
    private func addToHistory(image: UIImage, label: String) {
        let newSign = CapturedSign(image: image, label: label, date: Date())
        recentSigns.insert(newSign, at: 0)
        if recentSigns.count > 5 {
            recentSigns.removeLast()
        }
    }
    
    func start() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let currentImage = sampleBuffer.toUIImage(orientation: .up) else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        if let request = self.visionRequests.first as? VNCoreMLRequest {
            let requestClone = VNCoreMLRequest(model: request.model) { [weak self] req, err in
                self?.processFrame(request: req, error: err, originalImage: currentImage)
            }
            requestClone.imageCropAndScaleOption = request.imageCropAndScaleOption
            try? handler.perform([requestClone])
        }
    }
}


