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
    
    private func handleManualEntry(name: String, imageData: Data, lastContacted: Date) {
        let newContact = Contact(name: name, imageData: imageData, lastContacted: lastContacted)
        contacts.addContact(newContact)
    }
    
    let columns = [
        GridItem(.flexible(), spacing: .keetSpacingL),
        GridItem(.flexible(), spacing: .keetSpacingL)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if contacts.list.isEmpty {
                    EmptyStateView()
                } else {
                    LazyVGrid(columns: columns, spacing: .keetSpacingM) {
                        ForEach(contacts.list) { contact in
                            ContactCardView(contact: contact) {
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
            .background(Color.softCream)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        isShowingManualEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingManualEntry) {
                ManualEntryView(onSave: handleManualEntry)
            }
        }
        .tint(.terracotta) // Sets the accent color for the entire NavigationStack
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

