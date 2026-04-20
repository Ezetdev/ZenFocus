import WidgetKit
import SwiftUI

// 1. El proveedor de tiempo (define cuándo se actualiza el widget)
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date())
        // El widget no cambia de estado por sí solo ahora, es un acceso directo
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// 2. El modelo de datos del widget
struct SimpleEntry: TimelineEntry {
    let date: Date
}

// 3. El Diseño Visual del Widget
struct ZenFocusWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Fondo oscuro
            Color.black
            
            // Círculo decorativo
            Circle()
                .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 20)
                .padding(20)
                .opacity(0.6)
            
            VStack(spacing: 8) {
                Text("🧘")
                    .font(.title)
                
                Text("DEEP WORK")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .kerning(1.5)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("Ready?")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

// 4. Configuración principal del Widget

struct ZenFocusWidget: Widget {
    let kind: String = "ZenFocusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ZenFocusWidgetEntryView(entry: entry)
                // Esto quita los márgenes por defecto en iOS 17 para que el color llene todo
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("ZenFocus")
        .description("Acceso rápido a tus sesiones de enfoque profundo.")
        .supportedFamilies([.systemSmall]) // Solo permitimos el tamaño pequeño por ahora
    }
}
