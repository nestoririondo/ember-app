//
//  ContentView.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//

import SwiftUI
import Contacts
import ContactsUI

enum ViewMode {
       case bigGrid
       case smallGrid
}

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
}

struct ContentView: View {
    @State var contacts = ContactManager()
    @State private var contactToEdit: Contact? = nil
    @State private var contactForDatePicker: Contact? = nil
    @State private var viewMode: ViewMode = .bigGrid
    @State private var activeFilter: ContactFilter = .all
    
    private func handleSaveContact(contact: Contact?, name: String, imageData: Data, lastContacted: Date) {
        // Check if this was a temporary "create" contact (empty name) or a real edit
        if let existingContact = contact, !existingContact.name.isEmpty {
            // Real contact with data → EDIT
            contacts.updateContact(existingContact, name: name, imageData: imageData, lastContacted: lastContacted)
        } else {
            // Empty contact or nil → CREATE NEW
            let newContact = Contact(name: name, imageData: imageData, lastContacted: lastContacted)
            contacts.addContact(newContact)
        }
    }
    
    var columns: [GridItem] {
        switch viewMode {
        case .bigGrid:
            [
                GridItem(.flexible(), spacing: .keetSpacingL),
                GridItem(.flexible(), spacing: .keetSpacingL)
            ]
        case .smallGrid:
            [
                GridItem(.flexible(), spacing: .keetSpacingM),
                GridItem(.flexible(), spacing: .keetSpacingM),
                GridItem(.flexible(), spacing: .keetSpacingM)
            ]
        }
    }
  
    private func handleToggleViewMode() {
        switch viewMode {
        case .bigGrid:
            viewMode = .smallGrid
        case .smallGrid:
            viewMode = .bigGrid
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
        NavigationStack {
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
                                handleToggleViewMode()
                            }
                        } label: {
                            Image(systemName: viewMode == .bigGrid ? "rectangle.grid.3x2" : "square.grid.2x2")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .tint(.terracotta)
        .sheet(item: $contactToEdit) { contact in
            ManualEntryView(contact: contact) { name, imageData, lastContacted in
                handleSaveContact(contact: contact, name: name, imageData: imageData, lastContacted: lastContacted)
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
            contactsGrid
        }
    }
    
    private var contactsGrid: some View {
        LazyVGrid(columns: columns, spacing: .keetSpacingM) {
            ForEach(filteredContacts) { contact in
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
            Button(role: .confirm){
                showEditContact(for: contact)
            } label: {
                Label("Edit", systemImage: "square.and.pencil")
            }
            Button(role: .confirm) {
                showDatePicker(for: contact)
            } label: {
                Label("Set last contact date", systemImage: "calendar")
            }
            
            Button(role: .confirm) {
                contacts.updateLastContactedYesterday(for: contact)
            } label: {
                Label("Contacted yesterday", systemImage: "calendar.badge.clock")
            }
            Divider()
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.3)) {
                    contacts.deleteContact(contact)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var addButton: some View {
        Button {
            showCreateContact()
        } label: {
            Image(systemName: "plus")
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ContactFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        count: contacts.list.filter { filter.matches(contact: $0) }.count,
                        isSelected: activeFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            activeFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, .keetSpacingL)
        }
    }
}

// MARK: - Filter Chip Component
struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.keetCaption)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(isSelected ? Color.terracotta : Color.warmBrown.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.3) : Color.warmBrown.opacity(0.1))
                        )
                }
            }
            .foregroundStyle(isSelected ? Color.white : Color.warmBrown)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.terracotta : Color.cardBackground)
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.clear : Color.warmBrown.opacity(0.2),
                        lineWidth: 1
                    )
            )
            .keetShadow(intensity: isSelected ? .medium : .light)
        }
        .buttonStyle(.plain)
    }
}

//#Preview("Empty") {
//    ContentView(contacts: ContactManager())
//}
//

#Preview("With Contacts") {
    let viewModel = ContactManager()
    viewModel.list = Contact.examples
    return ContentView(contacts: viewModel)
    
}

//#Preview("Dark Mode") {
//    let viewModel = ContactManager()
//    viewModel.list = Contact.examples
//    return ContentView(contacts: viewModel)
//        .preferredColorScheme(.dark)
//}
