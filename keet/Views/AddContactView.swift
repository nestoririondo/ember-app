//
//  AddContactView.swift
//  keet
//
//  Created by Néstor on 16.12.25.
//

import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    
    let onSave: (Contact) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .font(.keetBody) // Design system font
                } header: {
                    Text("Contact Name")
                        .font(.keetCaption) // Design system font
                        .foregroundStyle(Color.warmBrown) // Explicit Color prefix
                }
            }
            .scrollContentBackground(.hidden) // Hide default form background
            .background(Color.softCream) // Design system background
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.warmBrown) // Explicit Color prefix
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveContact()
                    }
                    .foregroundStyle(Color.terracotta) // Explicit Color prefix
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .tint(.terracotta) // Design system accent for the entire view
    }
    
    private func saveContact() {
        let contact = Contact(
            name: name.trimmingCharacters(in: .whitespaces),
            initialInteraction: Date()
        )
        onSave(contact)
        dismiss()
    }
}

#Preview {
    AddContactView { contact in
        print("Saved: \(contact.name)")
    }
}
