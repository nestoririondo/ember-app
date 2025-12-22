//
//  ContactsViewModel.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//

import Foundation
import SwiftData

@Observable
class ContactManager {
    var list: [Contact] = []
    
    func addContact(_ contact: Contact) {
        list.append(contact)
        save()
    }
    
    func updateContact(_ contact: Contact, name: String, imageData: Data?, lastContacted: Date, category: ContactCategory, birthdayDate: Date?) {
        if let index = list.firstIndex(where: { $0.id == contact.id }) {
            list[index].name = name
            list[index].imageData = imageData
            list[index].category = category
            list[index].birthdayDate = birthdayDate
            
            // Replace the last interaction date with the new one
            if !list[index].interactions.isEmpty {
                list[index].interactions[list[index].interactions.count - 1] = lastContacted
            } else {
                list[index].interactions = [lastContacted]
            }
            save()
        }
    }
    
    func updateLastContacted(for contact: Contact, date: Date = Date()) {
        if let index = list.firstIndex(where: { $0.id == contact.id }) {
            list[index].interactions.append(date)
            save()
        }
    }
    
    func updateLastContactedYesterday(for contact: Contact) {
        if let index = list.firstIndex(of: contact) {
            list[index].interactions.append(Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
            save()
        }
    }
        
    func deleteContact(_ contact: Contact) {
        list.removeAll { $0.id == contact.id }
        save()
    }
    
    private var saveFileURL: URL {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        return documentsDirectory.appendingPathComponent("contacts.json")
    }
    
    private func load() {
        guard FileManager.default.fileExists(atPath: saveFileURL.path) else {
            print("ℹ️ No saved data found (first launch)")
            list = []
            return
        }
        
        do {
            let data = try Data(contentsOf: saveFileURL)
            
            // Try to decode with new format
            do {
                list = try JSONDecoder().decode([Contact].self, from: data)
                print("✅ Loaded \(list.count) contacts with new format")
            } catch {
                // Migration: Try to decode old format without category
                print("⚠️ Attempting to migrate old data format...")
                list = try migrateOldFormat(from: data)
                print("✅ Successfully migrated \(list.count) contacts")
                // Save in new format
                save()
            }
            
            // Validate data integrity
            validateContacts()
            
        } catch {
            print("⚠️ Failed to load: \(error.localizedDescription)")
            handleCorruptedData()
        }
    }
    
    private func migrateOldFormat(from data: Data) throws -> [Contact] {
        // Decode old contacts (without category field)
        struct OldContact: Decodable {
            let id: UUID
            var name: String
            var imageData: Data?
            var interactions: [Date]
        }
        
        let oldContacts = try JSONDecoder().decode([OldContact].self, from: data)
        
        // Convert to new format with default category
        return oldContacts.map { old in
            Contact(
                id: old.id,
                name: old.name,
                imageData: old.imageData,
                interactions: old.interactions,
                category: .friends  // Default to friends for migrated data
            )
        }
    }
    
    private func validateContacts() {
        // Remove any invalid contacts
        list.removeAll { contact in
            let isInvalid = contact.name.isEmpty || contact.interactions.isEmpty
            if isInvalid {
                print("⚠️ Removing invalid contact: \(contact.id)")
            }
            return isInvalid
        }
    }
    
    private func handleCorruptedData() {
        print("🔧 Attempting to recover data...")
        
        // Try to backup the corrupted file
        let backupURL = saveFileURL.deletingPathExtension().appendingPathExtension("backup.json")
        try? FileManager.default.copyItem(at: saveFileURL, to: backupURL)
        print("📦 Backed up corrupted data to: \(backupURL.path)")
        
        // Delete corrupted file
        try? FileManager.default.removeItem(at: saveFileURL)
        print("🗑️ Removed corrupted data file")
        
        // Start fresh
        list = []
        print("✨ Starting with empty contact list")
    }
    
    private func save() {
        // Validate before saving
        let validContacts = list.filter { !$0.name.isEmpty && !$0.interactions.isEmpty }
        
        do {
            let data = try JSONEncoder().encode(validContacts)
            try data.write(to: saveFileURL, options: .atomic)
            print("✅ Saved \(validContacts.count) contacts")
        } catch {
            print("❌ Failed to save: \(error.localizedDescription)")
        }
    }
    
    init() {
        // Wrap load in a do-catch to prevent crashes on launch
        do {
            try loadSafely()
        } catch {
            print("❌ Critical error during init: \(error)")
            // Emergency fallback: start with empty list
            list = []
            print("🆘 Emergency reset: Started with empty list")
        }
    }
    
    private func loadSafely() throws {
        load()
    }
    
    // MARK: - Debug Helpers
    
    /// Clear all saved data (useful for debugging)
    func clearAllData() {
        list = []
        try? FileManager.default.removeItem(at: saveFileURL)
        print("🗑️ All data cleared")
    }
    
    /// Get the file path for debugging
    func getDataPath() -> String {
        return saveFileURL.path
    }
}
