import Foundation

struct DetectedObject: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double
    let rect: CGRect
    //Delete color, it belong view layer
}

