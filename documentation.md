# Project Documentation

This document provides an overview of the files and their functionalities in the Repomax application codebase.

**Note:** There appear to be two potential locations for the application's source code within this workspace:
1.  `/Sources/repomax/`: This follows the Swift Package Manager (SPM) structure, likely defined in `Package.swift`.
2.  `/repomax/repomax/`: This follows a standard Xcode project structure and includes additional Xcode-specific files.

It's important to identify which set of files is actively used for development. This documentation primarily describes the files found, noting differences where apparent. The files listed under `/repomax/repomax/` seem to represent the more complete Xcode project setup.

## File Breakdown (Common & Xcode Project Files)

### `repomaxApp.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- This is the main entry point of the application.
- Sets up the main `WindowGroup` and the initial `ContentView`.
- Manages the application's lifecycle and main window behavior.
- Initializes and provides the `AppState` object to the environment.
- Defines basic application commands, such as "New Project".

### `ContentView.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- Defines the main user interface layout of the application using a horizontal split view.
- Contains the `SidebarView` (left pane) and the main content area (right pane).
- Switches the main content area between `ApplyView` and `ComposeView` based on the selected tab managed by `AppState`.
- Manages the presentation of various modal sheets for settings, role prompts, and the merge modal.
- **Includes nested views and structs:**
    - `TabBarView`: Handles the selection between "Compose" and "Apply" modes and the settings button.
    - `SidebarView`: Contains the file explorer, search bar, toolbar buttons (Open Folder, Clear, Refresh, Edit .gitignore), recent workspaces list, and the file tree view.
    - `FileTreeItemView`: Represents a single file or folder in the file tree, handling expansion, selection, and visual presentation.
    - `CheckboxView`: A custom checkbox style used in the file tree.
    - `ApplyView`: The view for applying AI code changes, including a text editor for AI responses, action buttons (Review & Apply, Clear, Undo All), and usage instructions.
    - `ComposeView`: The view for composing prompts and selecting files for AI analysis, including toggles for Code Map and XML Format, role selection (Architect, Engineer, Custom), an instructions text editor, a list of selected files with token information, and a copy to clipboard function.
    - `Pill`: A small view used to display selected components in the Compose view.
    - `SettingsView`: Configures XML format options (Diff or Whole).
    - `RolePromptView`: Displays the details of the currently selected AI role prompt.
    - `SelectedFile`: A data structure representing a file selected for analysis, including path, name, size (tokens), and percentage of total tokens.
    - `FileItemView`: Displays a selected file within the Compose view, showing its name, token size, and a percentage indicator.

### `FileTreeOptionsView.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- Defines a view presented as a sheet for configuring options related to the file tree and code map.
- Allows users to select the file display mode (Auto, Files, Selected).
- Includes an option to include root directories when files are selected.
- Provides settings for Code Map usage (Auto, Always, Never).
- Contains a custom `CheckboxToggleStyle`.

### `IgnorePatternsView.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- Defines a view for managing file ignore patterns.
- Allows editing of patterns for "Local Folder" (intended for `.repo_ignore`) or "Global Default" scopes.
- Explains how local and global patterns are combined and how local patterns override global ones.
- Provides a text editor for inputting ignore patterns.
- Includes buttons to Cancel or Save the changes, which updates the `AppState` and `UserDefaults`.

### `Persistence.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- Sets up and manages the Core Data stack for the application.
- Handles the creation and loading of the `NSPersistentContainer`.
- Includes configurations for both persistent storage and in-memory storage (for previews/testing).
- Sets up automatic merging of changes from the parent context.

### `MergeModalView.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- Defines a modal view displayed when reviewing pending code changes before applying them.
- Presents a list of files with proposed changes (Create, Modified, Deleted).
- Allows the user to select which individual file changes to apply using checkboxes.
- Includes buttons to Cancel or Apply the selected changes.
- **Includes nested views and structs:**
    - `FileChangeRowView`: Displays a single file change in the list, indicating its name, path, type of change, and a selection checkbox.
    - `CodeView`: A helper view for displaying code content in a scrollable, monospaced text view.
    - `MergeFileChange`: A data structure representing a pending file change with details like file name, path, type of change, and new content.

### `AppState.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- A central `ObservableObject` class managing the application's state.
- Holds published properties for various UI states, data models, and settings (e.g., selected tab, file tree, selected files, search text, AI response, current role, clipboard settings, etc.).
- Contains logic for:
    - Loading and filtering the file tree.
    - Handling file and folder selection, including recursive selection/deselection.
    - Opening folders using `NSOpenPanel`.
    - Managing recent workspaces.
    - Applying and undoing pending code changes.
    - Parsing and applying virtual `.gitignore` patterns.
    - Calculating approximate token counts for selected files.
    - Managing built-in and custom AI role prompts.
    - Formatting and copying selected content (instructions, file map, file contents, role prompt, XML format) to the clipboard based on user settings.
    - Extracting code from AI response descriptions.
    - Managing pending file changes before merging.
    - Adding custom role prompts.
    - Filtering the file tree based on search text.
- **Includes nested enums and structs:**
    - `FormatOption`: Defines the format for AI output (`none`, `diff`, `whole`).
    - `FileViewMode`: Defines the display mode for selected files (`folder`, `file`).
    - `TabType`: Defines the main application tabs (`compose`, `apply`).
    - `Role`: Defines the available AI roles (`none`, `architect`, `engineer`, `custom`).
    - `CustomRole`: Represents a user-defined AI role with a name and prompt content.
    - `FileItem`: Represents an item (file or folder) in the file tree, including its name, path, type, expansion state, selection state, and children.
    - `ClipboardSettings`: Holds boolean flags for which components to include when copying to the clipboard (instructions, files, code map).
    - `FileChange`: Represents a pending change to a file, including file path, original content, new content, change type, and applied status.

### `RolePromptSelectorView.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- Defines a modal view for selecting or adding AI role prompts.
- Lists built-in roles (Architect, Engineer) and allows selecting them.
- Displays existing custom prompts and allows selecting them.
- Provides an interface to add new custom prompts with a name and content.

### `GitignoreParser.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- A simple struct for parsing `.gitignore` content.
- Extracts ignore patterns from a given string, filtering out comments and empty lines.
- Provides an `isIgnored` method for basic checking if a file path contains any of the parsed patterns.

### `ClipboardSettingsView.swift` (Found in both `Sources/repomax` and `repomax/repomax`)
- Defines a view for configuring which components are included when copying content to the clipboard.
- Includes toggles for including instructions, selected files, and the code map.
- Provides a "Copy Now" button to trigger the copy action with the current settings.
- Contains a `ClipboardCheckboxToggleStyle` struct (similar to one in `FileTreeOptionsView.swift`).

### `repomax.entitlements` (Found in `repomax/repomax`)
- Property list file configuring application capabilities and security settings.
- Enables the App Sandbox (`com.apple.security.app-sandbox`).
- Requests permission for read-only access to user-selected files (`com.apple.security.files.user-selected.read-only`).

### `repomax.xcdatamodeld/` (Found in `repomax/repomax`)
- A directory representing the Core Data model definition.
- Contains the schema, entities, attributes, and relationships used for data persistence managed by `Persistence.swift`.

### `Preview Content/` (Found in `repomax/repomax`)
- A directory holding assets used specifically for SwiftUI previews within Xcode.
- Allows developers to provide sample data or resources to make previews more representative without affecting the main application bundle.

### `Assets.xcassets/` (Found in `repomax/repomax`)
- The standard Xcode asset catalog directory.
- Manages application resources like the app icon, images, custom colors, and potentially other data assets used throughout the UI.

## SPM-Specific Files

### `repomax.swift` (Found only in `Sources/repomax`)
- A very minimal file (previously 3 lines). Its exact purpose in the SPM context is unclear without further inspection, but it doesn't appear central to the application logic documented elsewhere. It might be a placeholder or related to the SPM target definition.

### `Package.swift` (Found in workspace root)
- The manifest file for the Swift Package Manager.
- Defines the package structure, targets (like the `repomax` source directory), dependencies, and build configurations for the SPM part of the project. 