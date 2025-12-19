//
//  ContentView.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//

import SwiftUI

struct ContentView: View {
    @State var contacts = ContactManager()
    @State private var contactToEdit: Contact? = nil
    @State private var contactForDatePicker: Contact? = nil
    @State private var showingDebugAlert = false
    @AppStorage("viewMode") private var viewMode: ViewMode = .bigGrid
    @AppStorage("activeFilter") private var activeFilter: ContactFilter = .all
    
    private func handleSaveContact(contact: Contact?, name: String, imageData: Data, lastContacted: Date, category: ContactCategory) {
        if let existingContact = contact, !existingContact.name.isEmpty {
            contacts.updateContact(existingContact, name: name, imageData: imageData, lastContacted: lastContacted, category: category)
        } else {
            let newContact = Contact(name: name, imageData: imageData, lastContacted: lastContacted, category: category)
            contacts.addContact(newContact)
        }
    }
    
    private func handlePickDate(_ date: Date) {
        guard let contact = contactForDatePicker else { return }
        contacts.updateLastContacted(for: contact, date: date)
    }
    
    private func showDatePicker(for contact: Contact) {
        contactForDatePicker = contact
    }
    
    private func showEditContact(for contact: Contact) {
        contactToEdit = contact
    }
    
    private func showCreateContact() {
        // Create a temporary "empty" contact for the sheet
        contactToEdit = Contact(name: "", imageData: nil, lastContacted: Date())
    }
    
    private var filteredContacts: [Contact] {
        contacts.list.filter { activeFilter.matches(contact: $0) }
    }
    
    var body: some View {
        return NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        if !contacts.list.isEmpty {
                            Color.clear.frame(height: 50)
                        }
                        
                        contentView
                    }
                }
                .padding(.bottom, .keetSpacingL)
                .background(Color.softCream)
                
                // Floating Filter Bar on top
                if !contacts.list.isEmpty {
                    filterBar
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    if !contacts.list.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewMode.toggle()
                            }
                        } label: {
                            Image(systemName: viewMode.icon)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateContact()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .tint(.terracotta)
        .sheet(item: $contactToEdit) { contact in
            ManualEntryView(contact: contact) { name, imageData, lastContacted, category in
                handleSaveContact(contact: contact, name: name, imageData: imageData, lastContacted: lastContacted, category: category)
            }
        }
        .sheet(item: $contactForDatePicker) { contact in
            DatePickerView(
                initialDate: contact.lastContacted,
                onDateSelected: handlePickDate
            )
            .presentationDetents([.medium])
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if contacts.list.isEmpty {
            EmptyStateView()
        } else {
            ContactsGridView(
                contacts: filteredContacts,
                columns: viewMode.columns,
                onContactTap: { contact in
                    contacts.updateLastContacted(for: contact)
                },
                onEditContact: showEditContact,
                onSetDate: showDatePicker,
                onContactedYesterday: { contact in
                    contacts.updateLastContactedYesterday(for: contact)
                },
                onDeleteContact: { contact in
                    contacts.deleteContact(contact)
                }
            )
        }
    }
    
    private var filterBar: some View {
        FilterBarView(
            contacts: contacts.list,
            activeFilter: $activeFilter
        )
    }
}

// MARK: - Preview

#Preview("With Contacts") {
    let viewModel = ContactManager()
    viewModel.list = Contact.examples
    return ContentView(contacts: viewModel)
}

