# Repomax 🚀

[![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)](https://www.apple.com/macos/sonoma/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-latest-orange)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE) <!-- Add your LICENSE file -->

Repomax is a native macOS application designed to streamline interaction with AI models for code analysis and modification directly within your project folders. It provides a user-friendly interface to select files, compose prompts with context, manage AI roles, apply generated code changes, and more.

## ✨ Features

*   **Project Folder Integration:** Open and navigate local project folders using a familiar file tree view.
*   **Selective File Context:** Choose specific files and folders to include as context for AI prompts.
*   **Token Calculation:** Get an approximate token count for selected files to manage context window limits.
*   **Compose & Apply Modes:**
    *   **Compose View:** Craft detailed prompts, select files, choose AI roles (Architect, Engineer, or custom), configure output formats (Code Map, XML), and copy the complete context to the clipboard.
    *   **Apply View:** Paste AI responses, review proposed changes (create, modify, delete), and selectively apply them to your local files.
*   **File Tree Management:**
    *   Search and filter files within the open folder.
    *   Toggle visibility of ignored files.
    *   Configure file display modes (Auto, Files only, Selected only).
*   **Ignore Pattern Support:** Define local (`.repo_ignore`) and global ignore patterns (similar to `.gitignore`) to exclude specific files/folders from selection and context.
*   **AI Role Prompts:** Use built-in prompts (Architect, Engineer) or create and manage your own custom role prompts.
*   **Merge Review:** A dedicated modal (`MergeModalView`) allows reviewing each proposed file change before applying.
*   **Clipboard Control:** Fine-tune what gets copied to the clipboard (instructions, file list, code map, role prompt).
*   **Recent Workspaces:** Quickly access previously opened folders.
*   **Modern SwiftUI Interface:** Built entirely with the latest SwiftUI for a native macOS experience.
*   **Core Data Persistence:** Stores recent workspaces and potentially other settings.

## 📸 Screenshots

<!-- Add screenshots of the application here -->
*   *Main Interface (Compose Tab)*
*   *Main Interface (Apply Tab)*
*   *File Tree & Options*
*   *Merge Modal View*
*   *Settings*

## 📋 Requirements

*   macOS 14.0 (Sonoma) or later
*   Xcode 15.0 or later

## 🛠️ Setup & Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/fomoroller/repomax.git # Replace with your repo URL
    cd repomax
    ```
2.  **Open in Xcode:**
    *   Open the `repomax.xcodeproj` file located in the cloned directory with Xcode.
3.  **Build & Run:**
    *   Select the `repomax` target and choose `My Mac` as the destination.
    *   Press `Cmd + R` or click the "Run" button (▶) to build and run the application.

## 🚀 Usage

1.  **Open Folder:** Click the "Open Folder" button in the sidebar or use the `File > Open Folder...` menu item to select your project directory.
2.  **Compose Prompt:**
    *   Navigate to the "Compose" tab.
    *   Select files/folders in the file tree you want the AI to analyze. Checkboxes indicate selection.
    *   Use the toggles to include a "Code Map" (list of selected files) or format file contents as XML if needed.
    *   Choose an AI Role (or add a custom one via the "..." button).
    *   Write your instructions/prompt in the main text editor.
    *   Click the "Copy to Clipboard" button (or configure options via the gear icon next to it).
3.  **Get AI Response:** Paste the copied content into your preferred AI model interface and get the response.
4.  **Apply Changes:**
    *   Navigate to the "Apply" tab.
    *   Paste the AI's response (containing code changes, potentially wrapped in markdown code blocks) into the text editor.
    *   Click "Review & Apply".
    *   In the "Review Changes" modal, review each proposed file modification (created, modified, deleted).
    *   Uncheck any changes you *don't* want to apply.
    *   Click "Apply Selected Changes". The changes will be written to your local files.
5.  **Undo:** Use the "Undo All" button in the Apply view to revert the *last applied* set of changes.
6.  **Manage Ignores:** Click the "Edit .gitignore" button in the sidebar to manage local (`.repo_ignore`) or global ignore patterns.

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute, please follow these steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/your-feature-name`).
3.  Make your changes.
4.  Commit your changes (`git commit -m 'Add some feature'`).
5.  Push to the branch (`git push origin feature/your-feature-name`).
6.  Open a Pull Request.

Please ensure your code adheres to the project's coding style and includes relevant tests if applicable.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
