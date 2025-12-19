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
    
    @State private var collapsedCategories: Set<ContactCategory> = []
    
    private func toggleCategory(_ category: ContactCategory) {
        withAnimation(.spring(response: 0.3)) {
            if collapsedCategories.contains(category) {
                collapsedCategories.remove(category)
            } else {
                collapsedCategories.insert(category)
            }
        }
    }
    
    private func contactsInCategory(_ category: ContactCategory) -> [Contact] {
        contacts.filter { $0.category == category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .keetSpacingL) {
            ForEach(ContactCategory.allCases, id: \.self) { category in
                let categoryContacts = contactsInCategory(category)
                
                if !categoryContacts.isEmpty {
                    CategorySection(
                        category: category,
                        contacts: categoryContacts,
                        columns: columns,
                        isCollapsed: collapsedCategories.contains(category),
                        onToggle: { toggleCategory(category) },
                        onContactTap: onContactTap,
                        onEditContact: onEditContact,
                        onSetDate: onSetDate,
                        onContactedYesterday: onContactedYesterday,
                        onDeleteContact: onDeleteContact
                    )
                }
            }
        }
        .padding(.horizontal, .keetSpacingL)
        .padding(.bottom, 80)
    }
}

struct CategorySection: View {
    let category: ContactCategory
    let contacts: [Contact]
    let columns: [GridItem]
    let isCollapsed: Bool
    let onToggle: () -> Void
    let onContactTap: (Contact) -> Void
    let onEditContact: (Contact) -> Void
    let onSetDate: (Contact) -> Void
    let onContactedYesterday: (Contact) -> Void
    let onDeleteContact: (Contact) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: .keetSpacingM) {
            // Category Header
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Image(systemName: category.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.terracotta)
                    
                    Text(category.rawValue)
                        .font(.footnote)
                        .foregroundStyle(Color.warmBrown)
                    
                    Text("(\(contacts.count))")
                        .font(.keetCaption)
                        .foregroundStyle(Color.warmBrown.opacity(0.6))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.warmBrown.opacity(0.5))
                        .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Grid of contacts
            if !isCollapsed {
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
            }
        }
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
