//
//  DatePickerView.swift
//  keet
//
//  Created by Néstor on 18.12.25.
//

import SwiftUI

struct DatePickerView: View {
    let initialDate: Date?
    let onDateSelected: (Date) -> Void
    var title: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date
    
    init(initialDate: Date?, onDateSelected: @escaping (Date) -> Void, title: String) {
        self.initialDate = initialDate
        self.onDateSelected = onDateSelected
        self.title = title
        _selectedDate = State(initialValue: initialDate ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
            }
            .background(Color.softCream)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            onDateSelected(newValue)
            dismiss()
        }
    }
}
