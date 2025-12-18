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
    // take data from SwiftData
    var list: [Contact] = []
    
    func addContact(_ contact: Contact) {
        list.append(contact)
        save()
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
        do {
            let data = try Data(contentsOf: saveFileURL)
            list = try JSONDecoder().decode([Contact].self, from: data)
            print("✅ Loaded \(list.count) contacts")
        } catch {
            print("ℹ️ No saved data found (this is normal on first launch)")
            list = []
        }
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(list)
            try data.write(to: saveFileURL)
            print("✅ Saved to: \(saveFileURL.path)")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }
    
    init() {
        load()
    }
}
