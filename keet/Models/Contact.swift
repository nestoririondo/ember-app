//
//  Contact.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//


import SwiftUI
import Foundation

struct Contact: Identifiable, Equatable {
    let id: UUID  // No default value - will be set in initializers
    var name: String
    var image: ImageResource?
    var interactions: [Date] = []  // Array of all interaction dates (not optional!)
    
    /// Most recent interaction date
    var lastContacted: Date {
        interactions.max() ?? Date()  // Returns most recent date or now if empty
    }
    
    /// Human-readable contextual time (e.g., "today", "3 days ago", "a month ago")
    var lastContactedText: String {
        let daysSince = Calendar.current.dateComponents([.day], from: lastContacted, to: Date()).day ?? 0
        
        switch daysSince {
        case 0:
            return "today"
        case 1:
            return "yesterday"
        case 2...6:
            return "\(daysSince) days ago"
        case 7:
            return "a week ago"
        case 8...13:
            return "more than a week ago"
        case 14...17:
            return "2 weeks ago"
        case 18...27:
            return "almost a month ago"
        case 28...35:
            return "a month ago"
        case 36...60:
            return "over a month ago"
        case 61...90:
            return "2 months ago"
        default:
            return "more than 2 months ago"
        }
    }
    
    /// Days since last contact
    var daysSinceLastContact: Int {
        Calendar.current.dateComponents([.day], from: lastContacted, to: Date()).day ?? 0
    }
    
    // MARK: - Initializers
    
    /// Create a new contact with optional initial interaction
    init(name: String, image: ImageResource? = nil, initialInteraction: Date = Date()) {
        self.id = UUID()  // Generate new ID
        self.name = name
        self.image = image
        self.interactions = [initialInteraction]  // Starts with one interaction
    }
    
    /// Create contact with existing interactions (for loading from storage)
    init(id: UUID, name: String, image: ImageResource? = nil, interactions: [Date]) {
        self.id = id  // Use provided ID
        self.name = name
        self.image = image
        self.interactions = interactions
    }
}

// MARK: - Preview Helpers
extension Contact {
    static var example: Contact {
        Contact(
            name: "John Doe",
            image: .test1,
            initialInteraction: Date().addingTimeInterval(-3600)  // 1 hour ago
        )
    }
    
    static var examples: [Contact] {
        [
            Contact(
                name: "John Doe",
                image: .test1,
                initialInteraction: Date().addingTimeInterval(-3600)  // 1 hour ago
            ),
            Contact(
                name: "Jane Smith",
                image: .test2,
                initialInteraction: Date().addingTimeInterval(-864000)  // 10 days ago
            ),
            Contact(
                name: "Bob Johnson",
                image: .test3,
                initialInteraction: Date().addingTimeInterval(-1728000)  // 20 days ago
            ),
            Contact(
                name: "Alice Williams",
                initialInteraction: Date().addingTimeInterval(-6048000)  // 70 days ago
            )
        ]
    }
}
