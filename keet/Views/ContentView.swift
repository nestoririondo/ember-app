//
//  ContentView.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//

import SwiftUI

struct ContentView: View {
    @State var contacts = ContactManager()
    @State private var isShowingAddSheet = false
    
    // Using design system spacing tokens
    let columns = [
        GridItem(.flexible(), spacing: .keetSpacingL),
        GridItem(.flexible(), spacing: .keetSpacingL)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if contacts.list.isEmpty {
                    emptyStateView
                } else {
                    LazyVGrid(columns: columns, spacing: .keetSpacingM) {
                        ForEach(contacts.list) { contact in
                            ContactCardView(contact: contact) {
                                // Using design system animation
                                withAnimation(.keetSpring) {
                                    contacts.updateLastContacted(for: contact)
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    withAnimation(.keetSpring) {
                                        contacts.deleteContact(contact)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button(role: .confirm) {
                                    contacts.updateLastContactedYesterday(for: contact)
                                } label: {
                                    Label("Mark yesterday", systemImage: "calendar")
                                }
                            }
                        }
                    }
                    .padding(.keetSpacingL)
                    .padding(.bottom, 80)
                }
            }
            .padding(.trailing, .keetSpacingL)
            .padding(.bottom, .keetSpacingL)
            .background(Color.softCream) // Design system background color
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.terracotta) // Design system accent color
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddContactView { contact in
                    withAnimation(.keetSpring) {
                        contacts.addContact(contact)
                    }
                }
            }
        }
        .tint(.terracotta) // Sets the accent color for the entire NavigationStack
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Contacts",
            systemImage: "person.crop.circle.badge.plus",
            description: Text("Tap the + button to add your first contact")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.warmBrown) // Design system text color
        .symbolRenderingMode(.hierarchical)
        .symbolEffect(.bounce, value: contacts.list.isEmpty)
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

