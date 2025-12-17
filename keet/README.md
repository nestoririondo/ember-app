# Keet - Contacts App

A clean, modern contacts management app built with SwiftUI.

## Project Structure

```
keet/
├── App/
│   └── keetApp.swift              # App entry point
│
├── Models/
│   └── Contact.swift              # Contact data model
│
├── ViewModels/
│   └── ContactsViewModel.swift    # Business logic & state management
│
└── Views/
    ├── ContactsListView.swift     # Main contacts list screen
    ├── ContactCardView.swift      # Individual contact card component
    └── AddContactView.swift       # Add/create new contact sheet
```

## Architecture

### MVVM Pattern
- **Models**: Plain data structures (Contact)
- **Views**: SwiftUI views for the UI
- **ViewModels**: Observable objects that manage state and business logic

### Key Features
- ✅ Add contacts manually
- ✅ Search/filter contacts
- ✅ Delete contacts with swipe actions
- ✅ Clean, modern UI with floating action button
- ✅ Empty state handling
- ✅ Smooth animations

## File Organization Best Practices

### Models/
Contains pure data structures with no UI or business logic. Keep them:
- Identifiable for use in SwiftUI lists
- Simple and focused on data representation
- Include preview helpers in extensions

### ViewModels/
Observable classes that contain:
- State management (@Observable macro)
- Business logic (filtering, CRUD operations)
- Computed properties for derived data
- No SwiftUI imports (Foundation only)

### Views/
SwiftUI view components:
- **ListViews**: Full screen views with navigation
- **CardViews**: Reusable components
- **FormViews**: Input/edit screens
- Each view should be focused and composable

### App/
App lifecycle and configuration:
- App entry point with @main
- App-wide configuration
- Keep it minimal

## Tips for Scaling

As your app grows, consider adding:
- **Services/**: API clients, persistence managers
- **Utilities/**: Helper functions, extensions
- **Resources/**: Assets, localization files
- **Features/**: Group related views/viewmodels by feature

## Development

Built with:
- Swift 6
- SwiftUI
- @Observable macro (iOS 17+)
