import Foundation
import Combine
import AudioToolbox

@Observable
class TimerModel {
    var timeRemaining: TimeInterval = 5
    var isActive = false
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func reset() {
        timeRemaining = 5
        isActive = false
    }
    
    func playEndSound() {
        // Sonido de sistema estándar, no necesita librerías extrañas
        AudioServicesPlaySystemSound(1005)
    }
}
