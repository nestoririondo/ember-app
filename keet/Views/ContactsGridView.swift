//
//  ContactsGridView.swift
//  keet
//
//  Created by Néstor on 19.12.25.
//

import SwiftUI

struct ContactsGridView: View {
    let contacts: [Contact]
    let columns: [GridItem]
    let onContactTap: (Contact) -> Void
    let onEditContact: (Contact) -> Void
    let onSetDate: (Contact) -> Void
    let onContactedYesterday: (Contact) -> Void
    let onDeleteContact: (Contact) -> Void
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: .keetSpacingM) {
            ForEach(contacts) { contact in
                ContactCardView(contact: contact) {
                    onContactTap(contact)
                }
                .contextMenu {
                    Button(role: .confirm) {
                        onEditContact(contact)
                    } label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                    
                    Button(role: .confirm) {
                        onSetDate(contact)
                    } label: {
                        Label("Set last contact date", systemImage: "calendar")
                    }
                    
                    Button(role: .confirm) {
                        onContactedYesterday(contact)
                    } label: {
                        Label("Contacted yesterday", systemImage: "calendar.badge.clock")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        withAnimation(.spring(response: 0.3)) {
                            onDeleteContact(contact)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .padding(.keetSpacingL)
        .padding(.bottom, 80)
    }
}

#Preview {
    ScrollView {
        ContactsGridView(
            contacts: Contact.examples,
            columns: ViewMode.bigGrid.columns,
            onContactTap: { _ in },
            onEditContact: { _ in },
            onSetDate: { _ in },
            onContactedYesterday: { _ in },
            onDeleteContact: { _ in }
        )
    }
}
