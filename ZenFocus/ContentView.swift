import SwiftUI
import UIKit
import SwiftData

struct ContentView: View {
    @State private var model = TimerModel()
    @State private var t: Float = 0.0
    
    // Variable para controlar si mostramos la pantalla de historial
    @State private var showHistory = false
    
    // Esto nos da acceso a la base de datos de SwiftData
    @Environment(\.modelContext) private var context

    var body: some View {
        // ¡ESTE ES EL SECRETO! Sin esto, no hay barra superior para el botón
        NavigationStack {
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
                    // Animación fluida del fondo
                    withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                        t = 1.0
                    }
                }
                
                // 2. Capa de desenfoque (Glassmorphism)
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("ZEN FOCUS")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .kerning(4)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    // --- BOTONES DE TIEMPO ---
                    HStack(spacing: 20) {
                        ForEach([5, 15, 25], id: \.self) { mins in
                            Button(action: {
                                triggerHaptic()
                                model.setTime(mins)
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

                    // La vista ahora solo pide el texto ya formateado
                    Text(model.formattedTime)
                        .font(.system(size: 90, weight: .ultraLight, design: .rounded))
                        .foregroundStyle(.white)
                    
                    // Botón Central
                    Button(action: {
                        triggerHaptic()
                        withAnimation(.spring()) {
                            model.toggleTimer()
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
                    
                    // Botón de Reiniciar
                    if !model.isActive && model.timeRemaining < model.totalDuration {
                        Button("New Session") {
                            triggerHaptic()
                            model.reset()
                        }
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.top, 20)
                    }
                }
            }
            // --- BOTÓN DE HISTORIAL EN LA BARRA SUPERIOR ---
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        triggerHaptic()
                        showHistory.toggle()
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(.white)
                    }
                }
            }
            // Conecta el botón con la vista HistoryView
            .sheet(isPresented: $showHistory) {
                HistoryView()
            }
            // Guarda la sesión cuando el modelo avisa
            .onAppear {
                model.onSessionComplete = { duration in
                    let newSession = FocusSession(durationInMinutes: duration)
                    context.insert(newSession)
                    print("¡Sesión de \(duration) minutos guardada con éxito en la base de datos!")
                }
            }
        }
    }
    
    // --- Funciones exclusivas de la vista ---
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

// --- NUEVA VISTA PARA EL HISTORIAL ---
struct HistoryView: View {
    // Esto lee automáticamente los datos guardados ordenados por fecha
    @Query(sort: \FocusSession.date, order: .reverse) private var sessions: [FocusSession]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if sessions.isEmpty {
                    Text("Aún no tienes sesiones completadas. ¡Empieza a enfocarte!")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sessions) { session in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Deep Work")
                                    .font(.headline)
                                Text(session.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(session.durationInMinutes) min")
                                .font(.title3.bold())
                                .foregroundStyle(.indigo)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

