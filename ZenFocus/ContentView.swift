import SwiftUI
import UIKit

struct ContentView: View {
    @State private var model = TimerModel()
    @State private var t: Float = 0.0
    
    var body: some View {
        ZStack {
            // 1. Fondo Dinámico (MeshGradient)
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    .init(0, 0), .init(0.5, 0), .init(1, 0),
                    .init(0, 0.5), .init(sin(t) * 0.2 + 0.5, cos(t) * 0.2 + 0.5), .init(1, 0.5),
                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                ],
                colors: [
                    .black, .indigo, .purple,
                    .blue, .indigo, .black,
                    .indigo, .purple, .black
                ],
                background: .black
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    t = 1.0
                }
            }
            
            // 2. Capa de desenfoque (Glassmorphism)
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("ENFOQUE")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .kerning(4)
                    .foregroundStyle(.white.opacity(0.6))
                
                // --- NUEVOS BOTONES DE TIEMPO ---
                HStack(spacing: 20) {
                    ForEach([5, 15, 25], id: \.self) { mins in
                        Button(action: {
                            triggerHaptic()
                            model.timeRemaining = TimeInterval(mins * 60)
                            model.isActive = false
                        }) {
                            Text("\(mins)m")
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(model.timeRemaining == TimeInterval(mins * 60) ? .white.opacity(0.2) : .clear)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
                                .foregroundStyle(.white)
                        }
                    }
                }

                Text(formatTime(model.timeRemaining))
                    .font(.system(size: 90, weight: .ultraLight, design: .rounded))
                    .foregroundStyle(.white)
                
                // Botón Central
                Button(action: {
                    triggerHaptic()
                    withAnimation(.spring()) {
                        model.isActive.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: model.isActive ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundStyle(.black)
                    }
                }
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // 5. Botón de Reiniciar
                if !model.isActive && model.timeRemaining < 1500 {
                    Button("New Sesion") {
                        triggerHaptic()
                        model.reset()
                    }
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 20)
                }
            } // Fin VStack
        } // Fin ZStack
        .onReceive(model.timer) { _ in
            if model.isActive && model.timeRemaining > 0 {
                model.timeRemaining -= 1
                if model.timeRemaining == 0 {
                    model.isActive = false
                    model.playEndSound()
                }
            }
        }
    } // Fin Body
    
    // --- Funciones de apoyo ---
    func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

