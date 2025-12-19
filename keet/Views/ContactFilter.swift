//
//  ContactFilter.swift
//  keet
//
//  Created by Néstor on 19.12.25.
//

import Foundation

enum ContactFilter: String, CaseIterable {
    case all = "All"
    case burning = "🔥 Hot"
    case warm = "☀️ Warm"
    case cooling = "🌙 Cooling"
    case needsLove = "💙 Needs Love"
    
    func matches(contact: Contact) -> Bool {
        switch self {
        case .all:
            return true
        case .burning:
            return contact.daysSinceLastContact <= 7
        case .warm:
            return contact.daysSinceLastContact > 7 && contact.daysSinceLastContact <= 21
        case .cooling:
            return contact.daysSinceLastContact > 21 && contact.daysSinceLastContact <= 45
        case .needsLove:
            return contact.daysSinceLastContact > 45
        }
    }
    
    func count(in contacts: [Contact]) -> Int {
        contacts.filter { matches(contact: $0) }.count
    }
}
