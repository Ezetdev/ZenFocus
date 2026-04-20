//
//  ZenFocusApp.swift
//  ZenFocus
//
//  Created by Ezequiel Trenard Alvarez on 19/4/26.
//

import SwiftUI
import SwiftData

@main
struct ZenFocusApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Esto crea la base de datos automáticamente
        .modelContainer(for: FocusSession.self)
    }
}
