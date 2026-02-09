import Foundation
import SwiftData

@Model
class User {
    var id: UUID
    var name: String
    var licensePlate: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Detection.user)
        var detections: [Detection]?
    
    init(name: String, licensePlate: String = "") {
        self.id = UUID()
        self.name = name
        self.licensePlate = licensePlate
        self.createdAt = Date()
        self.detections = []
    }
}
