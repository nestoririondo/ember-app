//
//  DatePickerView.swift
//  keet
//
//  Created by Néstor on 18.12.25.
//

import SwiftUI

struct DatePickerView: View {
    let initialDate: Date
    let onDateSelected: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date
    
    init(initialDate: Date, onDateSelected: @escaping (Date) -> Void) {
        self.initialDate = initialDate
        self.onDateSelected = onDateSelected
        _selectedDate = State(initialValue: initialDate)
    }
    
    var body: some View {
        DatePicker(
            "Select Date",
            selection: $selectedDate,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(Color.softCream)
        .onChange(of: selectedDate) { oldValue, newValue in
            onDateSelected(newValue)
            dismiss()
        }
    }
}
