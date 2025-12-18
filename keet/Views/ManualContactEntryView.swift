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
    
    @State var name = ""
    @State var selectedImage: UIImage? = nil
    @State var lastContacted: Date = Date()
    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var isShowingContactImport: Bool = false
    @State private var isShowingCustomDatePicker: Bool = false
    
    let onSave: (String, Data, Date) -> Void
    
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // MARK: - Photo Picker
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
                
                // MARK: - Name Input
                VStack(spacing: 16) {
                    TextField("Enter name", text: $name)
                        .textInputAutocapitalization(.words)
                        .font(.keetBody)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.warmBrown.opacity(0.1), lineWidth: 1)
                        )
                    
                    // MARK: - Date Picker Button
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
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.warmBrown.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // MARK: - Import from Contacts Button
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
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .background(Color.softCream)
            .navigationTitle("New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.warmBrown)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.8) ?? Data()
                        onSave(name.trimmingCharacters(in: .whitespaces), imageData, lastContacted)
                        dismiss()
                    }
                    .foregroundStyle(Color.terracotta)
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .tint(.terracotta)
        .presentationDetents([.medium])
        
        .sheet(isPresented: $isShowingContactImport) {
            ContactPickerView { selectedContact in
                handleImportedContact(selectedContact)
            }
        }
        .sheet(isPresented: $isShowingCustomDatePicker) {
                DatePicker(
                    "Select Date",
                    selection: $lastContacted,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .background(Color.softCream)
                .navigationTitle("Pick a Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isShowingCustomDatePicker = false
                        }
                        .foregroundStyle(Color.terracotta)
                        .fontWeight(.semibold)
                    }
                }
                .onChange(of: lastContacted) {
                    isShowingCustomDatePicker = false
                }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    ManualEntryView { name, imageData, _ in
        print("Saved contact:", name, imageData.count, "bytes")
    }
}
