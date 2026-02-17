import Foundation

protocol DetectionRepositoryProtocol {
    func saveDetection(label: String, confidence: Double, imageData: Data?, for user: User) throws
    func fetchDetections(forUserId userId: String) -> [Detection]
    func deleteDetection(_ detection: Detection) throws
}

