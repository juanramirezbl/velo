import Foundation
import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var cameraManager: CameraManager
    
    private let detectionRepository: DetectionRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let sessionManager: SessionManagerProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var previousSignCount: Int = 0
    
    init(
        cameraManager: CameraManager = CameraManager(),
        detectionRepository: DetectionRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        sessionManager: SessionManagerProtocol
    ) {
        self.cameraManager = cameraManager
        self.detectionRepository = detectionRepository
        self.userRepository = userRepository
        self.sessionManager = sessionManager
        
        self.previousSignCount = cameraManager.recentSigns.count
        
        cameraManager.$recentSigns
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signs in
                guard let self = self else { return }
                if signs.count > self.previousSignCount, let newSign = signs.first {
                    self.saveDetection(sign: newSign)
                }
                self.previousSignCount = signs.count
            }
            .store(in: &cancellables)
        
        cameraManager.objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
                    .store(in: &cancellables)
    }
    
    // MARK: - Bounding Box Calculation
    func calculateBox(for detection: DetectedObject, in geometry: GeometryProxy) -> CGRect {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        let videoWidth: CGFloat = 1080
        let videoHeight: CGFloat = 1920
        
        let screenAspectRatio = screenWidth / screenHeight
        let videoAspectRatio = videoWidth / videoHeight
        
        var scale: CGFloat
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        if screenAspectRatio < videoAspectRatio {
            scale = screenHeight / videoHeight
            let scaledWidth = videoWidth * scale
            xOffset = (scaledWidth - screenWidth) / 2
        } else {
            scale = screenWidth / videoWidth
            let scaledHeight = videoHeight * scale
            yOffset = (scaledHeight - screenHeight) / 2
        }
        
        let rect = detection.rect
        let width = rect.width * videoWidth * scale
        let height = rect.height * videoHeight * scale
        let x = (rect.minX * videoWidth * scale) - xOffset
        let y = (screenHeight - (rect.minY * videoHeight * scale) - height) + yOffset
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // MARK: - Camera Lifecycle
    
    func startCamera() {
        cameraManager.start()
    }
    
    func stopCamera() {
        cameraManager.stop()
    }
    
    // MARK: - Persistence 
    
    private func saveDetection(sign: CapturedSign) {
        guard let user = userRepository.fetchUser(byId: sessionManager.currentUserId) else {
            print("Error: No hay usuario logueado")
            return
        }
        
        print("Guardando: \(sign.label) para \(user.name)")
        
        let imageData = sign.image.jpegData(compressionQuality: 0.8)
        
        do {
            try detectionRepository.saveDetection(
                label: sign.label,
                confidence: 0.90,
                imageData: imageData,
                for: user
            )
        } catch {
            print("Error al guardar detección: \(error)")
        }
    }
}

