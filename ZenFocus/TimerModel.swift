import Foundation
import AudioToolbox

@Observable
class TimerModel {
    var timeRemaining: TimeInterval = 300 // 5 minutos por defecto
    var totalDuration: TimeInterval = 300 // Para recordar cuánto duraba la sesión
    var isActive = false
    
    // Este "aviso" se disparará cuando el tiempo llegue a cero para que ContentView guarde los datos
    var onSessionComplete: ((Int) -> Void)?
    
    // Usamos un Timer nativo manejado internamente
    private var timer: Timer?
    
    // Propiedad calculada para darle el tiempo formateado a la vista
    var formattedTime: String {
        let mins = Int(timeRemaining) / 60
        let secs = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    func toggleTimer() {
        isActive.toggle()
        if isActive {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    func setTime(_ minutes: Int) {
        stopTimer()
        let seconds = TimeInterval(minutes * 60)
        timeRemaining = seconds
        totalDuration = seconds // Guardamos el tiempo total para la base de datos
    }
    
    func reset() {
        stopTimer()
        timeRemaining = totalDuration // Ahora reinicia al último tiempo seleccionado
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                self.playEndSound()
                
                // ¡Avisamos a la vista que terminamos y le pasamos los minutos completados!
                let minutes = Int(self.totalDuration / 60)
                self.onSessionComplete?(minutes)
            }
        }
    }
    
    private func stopTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func playEndSound() {
        AudioServicesPlaySystemSound(1005)
    }
}
