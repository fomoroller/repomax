import SwiftUI
import AppKit
// We're in the same module, so no need to import ViewHelpers

struct IgnorePatternsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var selectedScope = "Local Folder"
    @State private var ignorePatterns: String
    
    // Computed property for the selected folder name
    private var selectedFolderName: String {
        if let workspacePath = appState.currentWorkspacePath {
            return URL(fileURLWithPath: workspacePath).lastPathComponent
        }
        return "No Folder Selected"
    }
    
    // Computed property for the full .repo_ignore path
    private var repoIgnorePath: String {
        if let workspacePath = appState.currentWorkspacePath {
            return "\(workspacePath)/.repo_ignore"
        }
        return "No workspace selected"
    }
    
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
                        // Load local .repo_ignore if it exists
                        loadLocalIgnorePatterns()
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(selectedScope == "Local Folder" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Button("Global Default") {
                        selectedScope = "Global Default"
                        // Load global patterns
                        loadGlobalIgnorePatterns()
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(selectedScope == "Global Default" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Text(selectedScope == "Local Folder" ? 
                     "Local scope will create a .repo_ignore file upon save and will be combined with global defaults." :
                     "Global defaults apply to all projects unless overridden by local .repo_ignore files.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Folder")
                    .font(.headline)
                
                HStack {
                    Text(selectedFolderName)
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
                
                Text(repoIgnorePath)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Show current source of patterns
                if selectedScope == "Local Folder", let workspacePath = appState.currentWorkspacePath {
                    let repoIgnoreExists = FileManager.default.fileExists(atPath: "\(workspacePath)/.repo_ignore")
                    let gitignoreExists = FileManager.default.fileExists(atPath: "\(workspacePath)/.gitignore")
                    
                    if repoIgnoreExists {
                        Text("📄 Loaded from existing .repo_ignore")
                            .font(.caption)
                            .foregroundColor(.blue)
                    } else if gitignoreExists {
                        Text("📄 Loaded from .gitignore (will save to .repo_ignore)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("📄 No ignore file found (will create .repo_ignore)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
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
                    saveIgnorePatterns()
                }
                .buttonStyle(.borderedProminent)
                .disabled(appState.currentWorkspacePath == nil && selectedScope == "Local Folder")
            }
        }
        .padding()
        .frame(width: 600, height: 600)
        .onAppear {
            // Set default scope based on whether we have a workspace
            if appState.currentWorkspacePath != nil {
                selectedScope = "Local Folder"
                loadLocalIgnorePatterns()
            } else {
                selectedScope = "Global Default"
                loadGlobalIgnorePatterns()
            }
        }
        .onChange(of: appState.currentWorkspacePath) { workspacePath in
            // Reload patterns when workspace path changes
            if workspacePath != nil && selectedScope == "Local Folder" {
                loadLocalIgnorePatterns()
            }
        }
    }
    
    private func loadLocalIgnorePatterns() {
        guard let workspacePath = appState.currentWorkspacePath else { 
            return 
        }
        
        let repoIgnoreURL = URL(fileURLWithPath: workspacePath).appendingPathComponent(".repo_ignore")
        let gitignoreURL = URL(fileURLWithPath: workspacePath).appendingPathComponent(".gitignore")
        
        // Check file existence explicitly
        let repoIgnoreExists = FileManager.default.fileExists(atPath: repoIgnoreURL.path)
        let gitignoreExists = FileManager.default.fileExists(atPath: gitignoreURL.path)
        
        if repoIgnoreExists {
            do {
                let content = try String(contentsOf: repoIgnoreURL, encoding: .utf8)
                ignorePatterns = content
                return
            } catch {
                print("Error reading .repo_ignore: \(error)")
            }
        }
        
        if gitignoreExists {
            do {
                let content = try String(contentsOf: gitignoreURL, encoding: .utf8)
                ignorePatterns = content
                return
            } catch {
                print("Error reading .gitignore: \(error)")
            }
        }
        
        // Start with empty patterns for local scope if neither file exists
        ignorePatterns = ""
    }
    
    private func loadGlobalIgnorePatterns() {
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
        
        ignorePatterns = UserDefaults.standard.string(forKey: "virtualGitignore") ?? defaultPatterns
    }
    
    private func saveIgnorePatterns() {
        if selectedScope == "Local Folder" {
            // Save to .repo_ignore file in the workspace
            guard let workspacePath = appState.currentWorkspacePath else { 
                return 
            }
            
            let repoIgnoreURL = URL(fileURLWithPath: workspacePath).appendingPathComponent(".repo_ignore")
            
            do {
                try ignorePatterns.write(to: repoIgnoreURL, atomically: true, encoding: .utf8)
                
                // Apply the patterns to update the file tree immediately
                appState.applyVirtualGitignore(ignorePatterns)
            } catch let error as NSError {
                print("Error saving .repo_ignore file: \(error)")
                if error.domain == NSCocoaErrorDomain && error.code == 513 {
                    print("Permission denied - app may need elevated permissions or folder may be protected")
                    // TODO: Show user alert about permission issue
                }
            }
        } else {
            // Save to global defaults
            UserDefaults.standard.set(ignorePatterns, forKey: "virtualGitignore")
            
            // Apply the global patterns
            appState.applyVirtualGitignore(ignorePatterns)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}