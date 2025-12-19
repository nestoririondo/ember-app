//
//  FilterBarView.swift
//  keet
//
//  Created by Néstor on 19.12.25.
//

import SwiftUI

struct FilterBarView: View {
    let contacts: [Contact]
    @Binding var activeFilter: ContactFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ContactFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        count: filter.count(in: contacts),
                        isSelected: activeFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            activeFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, .keetSpacingL)
        }
    }
}

#Preview {
    @Previewable @State var filter: ContactFilter = .all
    
    return FilterBarView(
        contacts: Contact.examples,
        activeFilter: $filter
    )
}
