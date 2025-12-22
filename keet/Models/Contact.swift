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
    var birthdayDate: Date?
    
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
    
    var birthdayText: String? {
        guard birthdayDate != nil else { return nil }
        
        // Get the month and day from the stored birthday
        let birthdayComponents = Calendar.current.dateComponents([.month, .day], from: birthdayDate!)

        // Get current year
        let currentYear = Calendar.current.component(.year, from: Date())

        // Build a date for this year with that month/day
        var nextBirthdayComponents = DateComponents()
        nextBirthdayComponents.year = currentYear
        nextBirthdayComponents.month = birthdayComponents.month
        nextBirthdayComponents.day = birthdayComponents.day

        // Create the date for this year
        guard var finalBirthday = Calendar.current.date(from: nextBirthdayComponents) else {
            return nil
        }
        
        // Check if this year's birthday already passed (compare at day level only)
        let today = Calendar.current.startOfDay(for: Date())
        let birthdayAtMidnight = Calendar.current.startOfDay(for: finalBirthday)
        
        if birthdayAtMidnight < today {
            // Need next year instead
            nextBirthdayComponents.year! += 1
            guard let nextYearBirthday = Calendar.current.date(from: nextBirthdayComponents) else {
                return nil
            }
            finalBirthday = nextYearBirthday
        }
        
        // Now calculate days until finalBirthday
        let daysUntil = Calendar.current.dateComponents([.day], from: today, to: finalBirthday).day ?? 0
        
        // Return text based on daysUntil
        switch daysUntil {
        case 0:
            return "Today!"
        case 1:
            return "Tomorrow"
        case 2...6:
            return "\(daysUntil) days"
        case 7:
            return "1 Week"
        default:
            return nil  // Don't show if more than 7 days
        }
    }
    
    /// Days since last contact
    var daysSinceLastContact: Int {
        Calendar.current.dateComponents([.day], from: lastContacted, to: Date()).day ?? 0
    }
    
    // MARK: - Initializers
    
    /// Create a new contact with optional initial interaction
    init(name: String, imageData: Data? = nil, lastContacted: Date = Date(), category: ContactCategory = .friends, birthdayDate: Date? = nil) {
        self.id = UUID()  // Generate new ID
        self.name = name
        self.imageData = imageData
        self.interactions = [lastContacted]
        self.category = category
        self.birthdayDate = birthdayDate
    }
    
    /// Create contact with existing interactions (for loading from storage)
    init(id: UUID, name: String, imageData: Data? = nil, interactions: [Date], category: ContactCategory = .friends, birthdayDate: Date? = nil) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.interactions = interactions
        self.category = category
        self.birthdayDate = birthdayDate
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
                category: .family,
                birthdayDate: Date().addingTimeInterval(86400)
            ),
            Contact(
                name: "Jane Smith",
                imageData: UIImage.dataFromResource(.test2), // Converts Resource to Data
                lastContacted: Date().addingTimeInterval(-304000),  // 10 days ago
                category: .friends,
                birthdayDate: Date()
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
