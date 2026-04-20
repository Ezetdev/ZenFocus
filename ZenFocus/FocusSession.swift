//
//  FocusSession.swift
//  ZenFocus
//
//  Created by Ezequiel Trenard Alvarez on 20/4/26.
//

import Foundation
import SwiftData

// El macro @Model le dice a Apple que esto debe guardarse en la base de datos
@Model
class FocusSession {
    var id: UUID
    var date: Date
    var durationInMinutes: Int
    
    init(durationInMinutes: Int) {
        self.id = UUID()
        self.date = Date()
        self.durationInMinutes = durationInMinutes
    }
}
