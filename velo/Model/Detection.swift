import Foundation
import SwiftData
import SwiftUI

@Model
class Detection {
    var id: UUID
    var timestamp: Date
    var label: String
    var confidence: Double
    
    
    @Attribute(.externalStorage) var imageData: Data?
    
    var user: User?

    init(label: String, confidence: Double, imageData: Data?) {
        self.id = UUID()
        self.timestamp = Date()
        self.label = label
        self.confidence = confidence
        self.imageData = imageData
    }
}
