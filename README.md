# Repomax

Repomax is a macOS application designed to assist developers with AI-powered code understanding, generation, and modification. It provides a suite of tools to manage codebases, interact with AI models using configurable roles, and apply changes with a review process.

## Features

*   **Dual Pane Interface:** A familiar sidebar for file navigation and a main content area for AI interaction.
*   **Compose Mode:**
    *   Select files and folders for AI analysis.
    *   Craft prompts with specific instructions.
    *   Choose AI roles (Architect, Engineer, or custom-defined roles) to tailor AI responses.
    *   View token counts for selected files.
    *   Toggle options for including a code map or formatting output as XML (Diff or Whole file).
    *   Copy composed prompts and file contexts to the clipboard with configurable settings.
*   **Apply Mode:**
    *   View AI-generated code responses.
    *   Review and apply proposed code changes.
    *   Undo applied changes.
*   **File Management:**
    *   File tree explorer with search functionality.
    *   Open folders and manage recent workspaces.
    *   Support for `.repo_ignore` (local) and global ignore patterns, similar to `.gitignore`.
    *   Refresh file tree and clear selections.
*   **Code Change Management:**
    *   Modal view to review pending changes (Create, Modify, Delete) before applying.
    *   Select individual file changes to apply or discard.
*   **Customization:**
    *   Add and manage custom AI role prompts.
    *   Configure clipboard settings for copying content.
    *   Manage file tree display options and code map usage.
    *   Edit ignore patterns for local and global scopes.
*   **Persistence:** Uses Core Data for managing application data like recent workspaces and custom roles.

## Directory Structure

```
repomax/
├── Views/           # UI components and view logic
│   ├── ContentView.swift         # Main UI layout and logic (1700+ lines)
│   ├── RolePromptSelectorView.swift
│   ├── MergeModalView.swift
│   ├── IgnorePatternsView.swift
│   ├── FileTreeOptionsView.swift
│   └── ClipboardSettingsView.swift
├── Models/          # Data models and state management
│   ├── AppState.swift           # Central state management (900+ lines)
│   └── Persistence.swift        # Core Data stack management
├── Utilities/       # Helper classes and utilities
│   └── GitignoreParser.swift    # .gitignore pattern parsing
├── Resources/       # App resources and assets
├── Preview Content/ # SwiftUI preview assets
└── repomax.xcdatamodeld/  # Core Data model definition
```

## Project Structure Overview

The application is built with SwiftUI for macOS, following a clean architecture with separated concerns:

### Views Layer
*   **`ContentView.swift`:** The main UI layout component (1700+ lines) that:
    - Implements the dual-pane interface with sidebar and main content
    - Manages tab bar for Compose/Apply modes
    - Coordinates all modal presentations
    - Contains nested views for file tree, compose, and apply functionalities
*   **Supporting Views:**
    - `RolePromptSelectorView`: AI role management interface
    - `MergeModalView`: Code change review and application
    - `IgnorePatternsView`: Pattern management for file filtering
    - `FileTreeOptionsView`: File tree display configuration
    - `ClipboardSettingsView`: Clipboard content management

### State Management
*   **`AppState.swift`:** A comprehensive state manager (900+ lines) handling:
    - UI state coordination
    - File operations and selections
    - AI interactions and response processing
    - Settings and configuration management
    - Change tracking and application

### Data Layer
*   **`Persistence.swift`:** Core Data stack configuration and management
*   **`repomax.xcdatamodeld`:** Data model definitions for persistence
*   **`GitignoreParser.swift`:** Utility for parsing and applying ignore patterns

## Getting Started

1.  Ensure you have Xcode installed on your macOS system.
2.  Clone the repository.
3.  Open the `repomax.xcodeproj` file in Xcode.
4.  Build and run the application on a Mac running macOS 14 (Sonoma) or later.

## Technical Details

*   **Framework:** SwiftUI
*   **Language:** Swift
*   **Target OS:** macOS 14 (Sonoma) and later
*   **Data Persistence:** Core Data
*   **App Sandbox:** Enabled, with permission for read-only access to user-selected files.
*   **Testing:** Includes both unit tests (`repomaxTests/`) and UI tests (`repomaxUITests/`)

## Development Notes

- The application follows SwiftUI best practices with a focus on declarative UI and state management.
- Key components like `ContentView` and `AppState` are substantial in size and might benefit from further modularization in future updates.
- The project uses Core Data for persistent storage, with a well-defined data model for managing workspaces and custom roles.
- The codebase is organized into logical directories (Views, Models, Utilities) for better maintainability. 