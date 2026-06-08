import Foundation
import SwiftUI
import Combine

/// ViewModel for the driving dashboard.
///
/// Coordinates the camera manager, transforms the detection boxes to screen
/// coordinates and automatically persists every newly detected sign.
class DashboardViewModel: ObservableObject {
    @Published var cameraManager: any CameraManagerProtocol

    private let detectionRepository: DetectionRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let sessionManager: SessionManagerProtocol

    private var cancellables = Set<AnyCancellable>()
    /// Number of recent signs in the last emission, used to detect new ones.
    private var previousSignCount: Int = 0

    /// Injects the dependencies and subscribes to new signs in order to persist them.
    init(
        cameraManager: any CameraManagerProtocol = CameraManager(),
        detectionRepository: DetectionRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        sessionManager: SessionManagerProtocol
    ) {
        self.cameraManager = cameraManager
        self.detectionRepository = detectionRepository
        self.userRepository = userRepository
        self.sessionManager = sessionManager

        self.previousSignCount = cameraManager.recentSigns.count

        // When a new sign appears, it is persisted in the database.
        cameraManager.recentSignsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signs in
                guard let self = self else { return }
                if signs.count > self.previousSignCount, let newSign = signs.first {
                    self.saveDetection(sign: newSign)
                }
                self.previousSignCount = signs.count
            }
            .store(in: &cancellables)

        // Forwards the camera manager's changes to refresh the view.
        cameraManager.objectDidChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Bounding Box Calculation

    /// Converts a normalized Vision box into screen coordinates.
    ///
    /// Adjusts the scale and offset according to the aspect ratio of the video
    /// and the screen, so the box stays aligned with the real image.
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

    /// Starts the camera and the detection.
    func startCamera() {
        cameraManager.start()
    }

    /// Stops the camera and the detection.
    func stopCamera() {
        cameraManager.stop()
    }

    // MARK: - Persistence

    /// Persists a detected sign, linking it to the logged-in user.
    private func saveDetection(sign: CapturedSign) {
        guard let user = userRepository.fetchUser(byId: sessionManager.currentUserId) else {
            return
        }

        let imageData = sign.image.jpegData(compressionQuality: 0.8)

        do {
            try detectionRepository.saveDetection(
                label: sign.label,
                confidence: 0.90,
                imageData: imageData,
                for: user
            )
        } catch {
            // Non-critical save errors are ignored in production.
        }
    }
}
