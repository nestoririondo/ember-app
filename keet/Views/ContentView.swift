//
//  ContentView.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContentView: View {
    @State var contacts = ContactManager()
    @State private var isShowingManualEntry: Bool = false
    @State private var isShowingCustomDatePicker: Bool = false
    @State private var selectedContact: Contact? = nil
    
    private func handleManualEntry(name: String, imageData: Data, lastContacted: Date) {
        let newContact = Contact(name: name, imageData: imageData, lastContacted: lastContacted)
        contacts.addContact(newContact)
    }
    
    let columns = [
        GridItem(.flexible(), spacing: .keetSpacingL),
        GridItem(.flexible(), spacing: .keetSpacingL)
    ]
    
    private func handlePickDate(_ date: Date) {
        guard let contact = selectedContact else { return }
        contacts.updateLastContacted(for: contact, date: date)
    }
    
    private func showDatePicker(for contact: Contact) {
        selectedContact = contact
        isShowingCustomDatePicker = true
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                contentView
            }
            .padding(.trailing, .keetSpacingL)
            .padding(.bottom, .keetSpacingL)
            .background(Color.softCream)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
        }
        .tint(.terracotta)
        .sheet(isPresented: $isShowingManualEntry) {
            ManualEntryView(onSave: handleManualEntry)
        }
        .sheet(isPresented: $isShowingCustomDatePicker) {
            if let contact = selectedContact {
                DatePickerView(
                    initialDate: contact.lastContacted,
                    onDateSelected: handlePickDate
                )
                .presentationDetents([.medium])
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if contacts.list.isEmpty {
            EmptyStateView()
        } else {
            contactsGrid
        }
    }
    
    private var contactsGrid: some View {
        LazyVGrid(columns: columns, spacing: .keetSpacingM) {
            ForEach(contacts.list) { contact in
                contactCard(for: contact)
            }
        }
        .padding(.keetSpacingL)
        .padding(.bottom, 80)
    }
    
    private func contactCard(for contact: Contact) -> some View {
        ContactCardView(contact: contact) {
            contacts.updateLastContacted(for: contact)
        }
        .contextMenu {
            Button(role: .confirm) {
                showDatePicker(for: contact)
            } label: {
                Label("Contacted on...", systemImage: "calendar")
            }
            
            Button(role: .confirm) {
                contacts.updateLastContactedYesterday(for: contact)
            } label: {
                Label("Contacted yesterday", systemImage: "calendar.badge.clock")
            }
            
            Button(role: .destructive) {
                contacts.deleteContact(contact)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var addButton: some View {
        Button {
            isShowingManualEntry = true
        } label: {
            Image(systemName: "plus")
        }
    }
}

//#Preview("Empty") {
//    ContentView(contacts: ContactManager())
//}


#Preview("With Contacts") {
    let viewModel = ContactManager()
    viewModel.list = Contact.examples
    return ContentView(contacts: viewModel)
}

