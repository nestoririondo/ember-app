//
//  ManualContactEntryView.swift
//  keet
//
//  Created by Néstor on 17.12.25.
//

import SwiftUI

struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    
    let onSave: (String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .font(.keetBody)
                } header: {
                    Text("Contact Name")
                        .font(.keetCaption)
                        .foregroundStyle(Color.warmBrown)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.softCream)
            .navigationTitle("Enter Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.warmBrown)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(name.trimmingCharacters(in: .whitespaces))
                    }
                    .foregroundStyle(Color.terracotta)
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .tint(.terracotta)
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.hidden)
    }
}
