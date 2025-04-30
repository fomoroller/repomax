# RepoMax Development Guide

## Build & Run Commands
- Build: `xcodebuild -project repomax.xcodeproj -scheme repomax build`
- Run: Open repomax.xcodeproj in Xcode and press ⌘R
- Test: `xcodebuild -project repomax.xcodeproj -scheme repomax test`
- Run specific test: `xcodebuild -project repomax.xcodeproj -scheme repomax test -only-testing:repomaxTests/YourTestName`

## Code Style Guidelines
- **Naming**: Use descriptive camelCase for variables/properties and PascalCase for types
- **Structure**: Group related properties and use MARK comments to organize sections
- **SwiftUI Views**: Extract subviews for reusability and readability
- **State Management**: Use @Published properties in AppState for centralized state
- **Error Handling**: Use try/catch with meaningful error messages
- **File Organization**: 
  - AppState.swift: Core state and data models
  - *View.swift: UI components
  - Parser implementations in dedicated files
- **Imports**: Only import what's needed (SwiftUI, AppKit, Combine)
- **Documentation**: Add comments for complex logic, especially file tree and parsing operations