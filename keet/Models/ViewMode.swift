//
//  ViewMode.swift
//  keet
//
//  Created by Néstor on 19.12.25.
//

import SwiftUI

enum ViewMode: String, CaseIterable {
    case bigGrid
    case smallGrid
    
    var columns: [GridItem] {
        switch self {
        case .bigGrid:
            return [
                GridItem(.flexible(), spacing: .keetSpacingL),
                GridItem(.flexible(), spacing: .keetSpacingL)
            ]
        case .smallGrid:
            return [
                GridItem(.flexible(), spacing: .keetSpacingM),
                GridItem(.flexible(), spacing: .keetSpacingM),
                GridItem(.flexible(), spacing: .keetSpacingM)
            ]
        }
    }
    
    var icon: String {
        switch self {
        case .bigGrid:
            return "rectangle.grid.3x2"
        case .smallGrid:
            return "square.grid.2x2"
        }
    }
    
    mutating func toggle() {
        switch self {
        case .bigGrid:
            self = .smallGrid
        case .smallGrid:
            self = .bigGrid
        }
    }
}
