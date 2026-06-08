import Foundation

/// Contract for the speech-synthesis service.
protocol SpeechServiceProtocol {
    /// Speaks aloud the alert corresponding to the sign label.
    func speak(label: String)
}
