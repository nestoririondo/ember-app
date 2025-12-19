//
//  Contact.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//


import SwiftUI
import Foundation

enum ContactCategory: String, Codable, CaseIterable {
    case family = "Family"
    case friends = "Friends"
    
    var icon: String {
        switch self {
        case .family: return "house.fill"
        case .friends: return "person.2.fill"
        }
    }
}

struct Contact: Identifiable, Equatable, Codable {
    let id: UUID  // No default value - will be set in initializers
    var name: String
    var imageData: Data?
    var interactions: [Date] = []  // Array of all interaction dates (not optional!)
    var category: ContactCategory = .friends  // Default to friends
    
    /// Most recent interaction date
    var lastContacted: Date {
        interactions.last ?? Date()  // Returns most recent date or now if empty
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
    init(name: String, imageData: Data? = nil, lastContacted: Date = Date(), category: ContactCategory = .friends) {
        self.id = UUID()  // Generate new ID
        self.name = name
        self.imageData = imageData
        self.interactions = [lastContacted]
        self.category = category
    }
    
    /// Create contact with existing interactions (for loading from storage)
    init(id: UUID, name: String, imageData: Data? = nil, interactions: [Date], category: ContactCategory = .friends) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.interactions = interactions
        self.category = category
    }
}

// MARK: - Preview Helpers
extension Contact {
    static var example: Contact {
        Contact(
            name: "John Doe",
//            image: .test1,
            lastContacted: Date().addingTimeInterval(-3600)  // 1 hour ago
        )
    }
    
    static var examples: [Contact] {
        [
            Contact(
                name: "John Doe",
                imageData: UIImage.dataFromResource(.test1), // Converts Resource to Data
                lastContacted: Date().addingTimeInterval(-3600),  // 1 hour ago
                category: .family
            ),
            Contact(
                name: "Jane Smith",
                imageData: UIImage.dataFromResource(.test2), // Converts Resource to Data
                lastContacted: Date().addingTimeInterval(-864000),  // 10 days ago
                category: .friends
            ),
            Contact(
                name: "Bob Johnson",
                imageData: UIImage.dataFromResource(.test3), // Converts Resource to Data
                lastContacted: Date().addingTimeInterval(-6048000),  // 20 days ago
                category: .family
            ),
            Contact(
                name: "Alice Williams",
                lastContacted: Date().addingTimeInterval(-6048000),  // 70 days ago
                category: .friends
            ),
            Contact(
                name: "Alice Williams2",
                imageData: UIImage.dataFromResource(.test4), // Converts Resource to Data

                lastContacted: Date().addingTimeInterval(-554000),  // 70 days ago
                category: .friends
            )
        ]
    }
}

extension UIImage {
    static func dataFromResource(_ resource: ImageResource) -> Data? {
        return UIImage(resource: resource).jpegData(compressionQuality: 0.8)
    }
}
