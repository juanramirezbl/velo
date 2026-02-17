import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published var detections: [Detection] = []
    
    private let detectionRepository: DetectionRepositoryProtocol
    private let userId: String
    
    init(userId: String, detectionRepository: DetectionRepositoryProtocol) {
        self.userId = userId
        self.detectionRepository = detectionRepository
        loadDetections()
    }
    
    func loadDetections() {
        detections = detectionRepository.fetchDetections(forUserId: userId)
    }
    
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

