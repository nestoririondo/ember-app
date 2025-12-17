//
//  ContactsViewModel.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//

import Foundation

@Observable
class ContactManager {
    var list: [Contact] = []
    
    func addContact(_ contact: Contact) {
        list.append(contact)
    }
    
    func updateLastContacted(for contact: Contact) {
        if let index = list.firstIndex(where: { $0.id == contact.id }) {
            list[index].interactions.append(Date())
        }
    }
    
    func updateLastContactedYesterday(for contact: Contact) {
        if let index = list.firstIndex(of: contact) {
            list[index].interactions.append(Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        }
    }
    
    func deleteContact(_ contact: Contact) {
        list.removeAll { $0.id == contact.id }
    }
}
