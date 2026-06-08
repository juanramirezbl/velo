import Foundation
import SwiftData

/// SwiftData-backed implementation of the detection repository.
class DetectionRepository: DetectionRepositoryProtocol {
    private let modelContext: ModelContext

    /// Creates the repository with the persistence context it will use.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Creates a detection, links it to the user and persists the changes.
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

    /// Returns the given user's detections ordered by descending date.
    func fetchDetections(forUserId userId: String) -> [Detection] {
        guard let uuid = UUID(uuidString: userId) else { return [] }
        let predicate = #Predicate<Detection> { detection in
            detection.user?.id == uuid
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.timestamp, order: .reverse)]
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Deletes the given detection and saves the changes.
    func deleteDetection(_ detection: Detection) throws {
        modelContext.delete(detection)
        try modelContext.save()
    }
}
