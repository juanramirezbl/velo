import Foundation

/// Contract for detection data access.
protocol DetectionRepositoryProtocol {
    /// Saves a detection associated with a user.
    func saveDetection(label: String, confidence: Double, imageData: Data?, for user: User) throws
    /// Returns a user's detections ordered from newest to oldest.
    func fetchDetections(forUserId userId: String) -> [Detection]
    /// Deletes the given detection.
    func deleteDetection(_ detection: Detection) throws
}
