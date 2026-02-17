import Foundation
import SwiftData

class DetectionRepository: DetectionRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveDetection(label: String, confidence: Double, imageData: Data?, for user: User) throws {
        let newDetection = Detection(
            label: label,
            confidence: confidence,
            imageData: imageData
        )
        newDetection.user = user
        user.detections?.append(newDetection)
        try modelContext.save()
    }
    
    func fetchDetections(forUserId userId: String) -> [Detection] {
        guard let uuid = UUID(uuidString: userId) else { return [] }
        let predicate = #Predicate<Detection> { detection in
            detection.user?.id == uuid
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.timestamp, order: .reverse)]
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func deleteDetection(_ detection: Detection) throws {
        modelContext.delete(detection)
        try modelContext.save()
    }
}

