//
//  ContactPickerView.swift
//  keet
//
//  Created by Néstor on 17.12.25.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContactPickerView: UIViewControllerRepresentable {
    let onSelect: (CNContact) -> Void
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        
        picker.displayedPropertyKeys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactImageDataKey
        ]
        
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let onSelect: (CNContact) -> Void
        
        init(onSelect: @escaping (CNContact) -> Void) {
            self.onSelect = onSelect
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(contact)
            // No need to call dismiss - CNContactPickerViewController dismisses itself
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            // No need to call dismiss - CNContactPickerViewController dismisses itself
        }
    }
}
