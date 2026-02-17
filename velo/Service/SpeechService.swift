import AVFoundation

class SpeechService: SpeechServiceProtocol {
    
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(label: String) {
        let phrase = getSpanishPhrase(for: label)
        
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        utterance.rate = 0.50
        utterance.pitchMultiplier = 1.0
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Error: \(error)")
        }
        
        synthesizer.speak(utterance)
    }
    
    private func getSpanishPhrase(for label: String) -> String {
        let l = label.lowercased()
        
        if l.contains("prohibitory") { return "Señal de Prohibición detectada." }
        if l.contains("danger") { return "Señal de Peligro detectada." }
        if l.contains("mandatory") { return "Señal de Obligación detectada." }
        
        return "Señal detectada."
    }
}

