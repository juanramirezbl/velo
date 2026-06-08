import Foundation
import Combine

/// ViewModel for a user's detection history.
class HistoryViewModel: ObservableObject {
    @Published var detections: [Detection] = []

    private let detectionRepository: DetectionRepositoryProtocol
    private let userId: String

    /// Injects the repository and loads the detections of the given user.
    init(userId: String, detectionRepository: DetectionRepositoryProtocol) {
        self.userId = userId
        self.detectionRepository = detectionRepository
        loadDetections()
    }

    /// Reloads the user's detections from the repository.
    func loadDetections() {
        detections = detectionRepository.fetchDetections(forUserId: userId)
    }

    /// Deletes the detections at the given indices and refreshes the list.
    /// - Parameter offsets: positions selected for deletion (swipe gesture).
    func deleteDetection(at offsets: IndexSet) {
        for index in offsets {
            let detection = detections[index]
            do {
                try detectionRepository.deleteDetection(detection)
            } catch {
                print("Error al eliminar detección: \(error)")
            }
        }
        loadDetections()
    }
}
