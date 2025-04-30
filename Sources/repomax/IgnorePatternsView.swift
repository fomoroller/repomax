import SwiftUI
import AppKit
// We're in the same module, so no need to import ViewHelpers

struct IgnorePatternsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var selectedScope = "Local Folder"
    @State private var selectedFolder = "RepoMax"
    @State private var ignorePatterns: String
    
    init() {
        // Initialize with the current virtual gitignore or default patterns
        let defaultPatterns = """
        # Global ignore defaults
        **/node_modules/
        **/.npm/
        **/__pycache__/
        **/.pytest_cache/
        **/.mypy_cache/

        # Build caches
        **/.gradle/
        **/.nuget/
        **/.cargo/
        **/.stack-work/
        **/.ccache/

        # IDE and Editor caches
        **/.idea/
        **/.vscode/
        **/*.swp
        """
        
        _ignorePatterns = State(initialValue: UserDefaults.standard.string(forKey: "virtualGitignore") ?? defaultPatterns)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ignore Patterns")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Edit ignore patterns. Global defaults from your settings are always combined with any .repo_ignore file found in a folder. Local patterns (from .repo_ignore) will override global defaults.")
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Filter Scope")
                    .font(.headline)
                
                HStack(spacing: 0) {
                    Button("Local Folder") {
                        selectedScope = "Local Folder"
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(selectedScope == "Local Folder" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Button("Global Default") {
                        selectedScope = "Global Default"
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(selectedScope == "Global Default" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Text("Local scope will create a .repo_ignore file upon save and will be combined with global defaults.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Folder")
                    .font(.headline)
                
                HStack {
                    Text(selectedFolder)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    Image(systemName: "chevron.down")
                        .padding(.trailing, 8)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                Text("/Users/hannan/Documents/Code/repomax/RepoMax/.repo_ignore")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            TextEditor(text: $ignorePatterns)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.black.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save") {
                    // Save the ignore patterns
                    appState.applyVirtualGitignore(ignorePatterns)
                    
                    // Store in UserDefaults for persistence
                    UserDefaults.standard.set(ignorePatterns, forKey: "virtualGitignore")
                    
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 600, height: 600)
    }
}