//
//  ManualContactEntryView.swift
//  keet
//
//  Created by Néstor on 17.12.25.
//

import SwiftUI
import PhotosUI
struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
        
    @State var name = ""
    @State var selectedImage: UIImage? = nil
    @State private var avatarItem: PhotosPickerItem? = nil
    
    let onSave: (String, Data) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
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
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.warmBrown.opacity(0.1), lineWidth: 2))
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
                .onChange(of: avatarItem) {
                    Task {
                        if let data = try? await avatarItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImage = image
                        }
                    }
                }
                
                // MARK: - Name Input
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
            }
            .background(Color.softCream)
            .navigationTitle("Enter Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.warmBrown)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.8) ?? Data()
                        onSave(name.trimmingCharacters(in: .whitespaces), imageData)
                    }
                    .foregroundStyle(Color.terracotta)
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .tint(.terracotta)
        .presentationDetents([.medium]) // Increased height to fit the big avatar
    }
}
