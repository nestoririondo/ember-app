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
    @State private var isShowingContactImport: Bool = false
    @State private var isShowingManualEntry: Bool = false
    
    private func handleImportedContact(_ cnContact: CNContact) {
        let fullName = "\(cnContact.givenName) \(cnContact.familyName)"
            .trimmingCharacters(in: .whitespaces)

        let imageData = cnContact.thumbnailImageData

        let newContact = Contact(
            name: fullName.isEmpty ? "Unknown" : fullName,
            imageData: imageData
        )
        contacts.addContact(newContact)
        isShowingContactImport = false
    }
    
    private func handleManualEntry(_ name: String, image: Data? = nil) {
        let newContact = Contact(name: name, imageData: image)
        contacts.addContact(newContact)
        isShowingManualEntry = false
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
                    Menu {
                        Button{
                            isShowingContactImport = true
                        } label: {
                            Label("Import Contact", systemImage: "person.text.rectangle.fill")
                        }
                        Button{
                            isShowingManualEntry = true
                        } label: {
                            Label("Add manually", systemImage: "rectangle.and.pencil.and.ellipsis")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                }
            }
            .sheet(isPresented: $isShowingContactImport) {
                ContactPickerView { selectedContact in
                    handleImportedContact(selectedContact)
                }
            }
            .sheet(isPresented: $isShowingManualEntry) {
                ManualEntryView { name,image in
                    handleManualEntry(name,image: image)
                }
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

