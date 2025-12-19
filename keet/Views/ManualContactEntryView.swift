//
//  ManualContactEntryView.swift
//  keet
//
//  Created by Néstor on 17.12.25.
//

import SwiftUI
import PhotosUI
import ContactsUI

struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var name: String
    @State var selectedImage: UIImage?
    @State var lastContacted: Date
    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var isShowingContactImport: Bool = false
    @State private var isShowingCustomDatePicker: Bool = false
    @State private var showValidationTooltip: Bool = false
    
    let contact: Contact?
    let onSave: (String, Data, Date) -> Void
    
    init(contact: Contact?, onSave: @escaping (String, Data, Date) -> Void) {
        self.contact = contact
        self.onSave = onSave
        
        // Initialize state from contact (which might be empty for create mode)
        _name = State(initialValue: contact?.name ?? "")
        _lastContacted = State(initialValue: contact?.lastContacted ?? Date())
        
        // Convert image data to UIImage if available
        if let contact = contact,
           let imageData = contact.imageData,
           !imageData.isEmpty,
           let uiImage = UIImage(data: imageData) {
            _selectedImage = State(initialValue: uiImage)
        } else {
            _selectedImage = State(initialValue: nil)
        }
    }
    
    private var isCreating: Bool {
        // We're creating if the contact was passed with an empty name
        contact?.name.isEmpty ?? false
    }
    
    
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(lastContacted) {
            return "Today"
        } else if calendar.isDateInYesterday(lastContacted) {
            return "Yesterday"
        } else {
            return lastContacted.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    private func handleImportedContact(_ cnContact: CNContact) {
        name = "\(cnContact.givenName) \(cnContact.familyName)"
            .trimmingCharacters(in: .whitespaces)

        selectedImage = UIImage(data: cnContact.thumbnailImageData ?? Data())
    }
    
    private func handleAdd() {
        if isNameValid {
            let imageData = selectedImage?.jpegData(compressionQuality: 0.8) ?? Data()
            onSave(name.trimmingCharacters(in: .whitespaces), imageData, lastContacted)
            dismiss()
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showValidationTooltip = true
            }
            
            // Auto-hide after 2 seconds
            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation {
                    showValidationTooltip = false
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            mainContent
        }
        .tint(.terracotta)
        .presentationDetents([.medium])
        
        .sheet(isPresented: $isShowingContactImport) {
            ContactPickerView { selectedContact in
                handleImportedContact(selectedContact)
            }
        }
        .sheet(isPresented: $isShowingCustomDatePicker) {
            DatePickerView(
                initialDate: lastContacted,
                onDateSelected: { newDate in
                    lastContacted = newDate
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            // MARK: - Photo Picker
            photoPickerButton
            
            // MARK: - Information input
            VStack(spacing: 16) {
                enterNameTextfield
                
                pickDateButton
                
                importContactButton
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color.softCream)
        .navigationTitle(isCreating ? "New Contact" : "Edit Contact")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(Color.warmBrown)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isCreating ? "Add" : "Save") {
                    handleAdd()
                }
                .foregroundStyle(isNameValid ? Color.terracotta : Color.gray.opacity(0.5))
                .fontWeight(.semibold)
            }
        }
    }
    
    private var photoPickerButton: some View {
        PhotosPicker(selection: $avatarItem, matching: .images) {
            ZStack {
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle()
                        .fill(Color.warmBrown.opacity(0.2))
                    Image(systemName: "camera.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.warmBrown)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.warmBrown.opacity(0.1), lineWidth: 2))
        }
        .buttonStyle(.plain)
        .padding(.top, 32)
        .onChange(of: avatarItem) {
            Task {
                if let data = try? await avatarItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
    
    private var enterNameTextfield: some View {
        TextField("Enter name", text: $name)
            .textInputAutocapitalization(.words)
            .font(.keetBody)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.trailing, name.isEmpty ? 16 : 40) // Extra padding for clear button
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(alignment: .trailing) {
                if !name.isEmpty {
                    Button {
                        name = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.warmBrown.opacity(0.5))
                    }
                    .padding(.trailing, 12)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        showValidationTooltip ? Color.red.opacity(0.5) : Color.warmBrown.opacity(0.1),
                        lineWidth: showValidationTooltip ? 2 : 1
                    )
            )
            .overlay(alignment: .top) {
                if showValidationTooltip {
                    validationTooltip
                        .offset(y: -60)
                }
            }
    }

    
    private var pickDateButton: some View {
        Button {
            isShowingCustomDatePicker = true
        } label: {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 16))
                Text("Last contacted")
                    .font(.keetBody)
                Spacer()
                Text(formattedDate)
                    .font(.keetBody)
                    .foregroundStyle(Color.warmBrown.opacity(0.7))
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
            .foregroundStyle(Color.warmBrown)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.warmBrown.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var importContactButton: some View {
        Button {
            isShowingContactImport = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 16))
                Text("Import from Contacts")
                    .font(.keetCaption)
            }
            .foregroundStyle(Color.warmBrown)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    private var validationTooltip: some View {
        VStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.body)
                .foregroundStyle(Color.orange)
            Text("Please enter a name")
                .font(.keetCaption)
                .foregroundStyle(Color.warmBrown)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .transition(.scale.combined(with: .opacity))
    }
}

