import Foundation
import AVFoundation //Apple utils
import Combine // connect data with screen

class CameraManager: NSObject, ObservableObject {
    
    @Published var permissionGranted = false
    
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue") //better processing
    
    //data for Yolo
    private let videoOutput = AVCaptureVideoDataOutput()
    
    //permission
    override init() {
            super.init()
            checkPermission()
            sessionQueue.async { [weak self] in
                self?.configureSession()
                self?.session.startRunning()
            }
        }
        
        func checkPermission() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                permissionGranted = true
            case .notDetermined:
                requestPermission()
            default:
                permissionGranted = false
            }
        }
        
        func requestPermission() {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                }
            }
        }
    
    //configuration
    func configureSession() {
            guard permissionGranted else { return }
            
            session.beginConfiguration()
            session.sessionPreset = .hd1920x1080
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
            
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                
                videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
                            
                videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)// background = sessionQueue
            }
            
            session.commitConfiguration()
        }
}
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}
