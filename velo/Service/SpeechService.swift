import AVFoundation

/// Voice-alert service using Spanish speech synthesis.
class SpeechService: SpeechServiceProtocol {

    private let synthesizer = AVSpeechSynthesizer()

    /// Speaks the voice alert corresponding to the detected sign.
    ///
    /// Interrupts any ongoing utterance and ducks other audio sources
    /// (music, navigation) while speaking.
    func speak(label: String) {
        let phrase = getSpanishPhrase(for: label)

        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        utterance.rate = 0.50
        utterance.pitchMultiplier = 1.0

        // If it is already speaking, interrupt the previous utterance.
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        // Configure the audio session to play while ducking other sources.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Error: \(error)")
        }

        synthesizer.speak(utterance)
    }

    /// Maps the sign class label to the spoken message in Spanish.
    private func getSpanishPhrase(for label: String) -> String {
        let l = label.lowercased()

        if l.contains("prohibitory") { return "Señal de Prohibición detectada." }
        if l.contains("danger") { return "Señal de Peligro detectada." }
        if l.contains("mandatory") { return "Señal de Obligación detectada." }

        return "Señal detectada."
    }
}
