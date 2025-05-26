import SwiftUI
import Combine
import AppKit

@available(macOS 10.15, *)
@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: TabType = .compose
    @Published var fileTree: [FileItem] = []
    @Published var selectedFiles: Set<String> = []
    @Published var searchText: String = ""
    @Published var instructionsText: String = ""
    @Published var aiResponseText: String = ""
    @Published var selectedFileContent: String?
    @Published var selectedFilePath: String?
    @Published var showSettings: Bool = false
    @Published var showRolePrompt: Bool = false
    @Published var showRolePromptSelector: Bool = false
    @Published var showIgnorePatterns: Bool = false
    @Published var showMergeModal: Bool = false
    @Published var currentRole: Role = .none
    @Published var currentWorkspacePath: String? = nil
    @Published var recentWorkspaces: [String] = []
    @Published var virtualGitignore: String = ""
    @Published var formatOption: FormatOption = .none
    @Published var fileViewMode: FileViewMode = .folder
    @Published var clipboardSettings: ClipboardSettings = ClipboardSettings(includeFiles: true)
    var backupContents: [String: String] = [:]
    var pendingChanges: [FileChange] = []
    @Published var customRoles: [CustomRole] = []
    private var gitignoreParser: GitignoreParser?
    private var workspaceBasePath: String?
    
    enum FormatOption: String {
        case none = "None"
        case diff = "Diff"
        case whole = "Whole"
    }
    
    enum FileViewMode: String {
        case folder = "Folder"
        case file = "File"
    }
    
    enum TabType {
        case compose, apply
    }
    
    enum Role: Equatable {
        case none
        case architect
        case engineer
        case custom(String)
        
        // Custom implementation of Equatable to handle associated values
        static func == (lhs: Role, rhs: Role) -> Bool {
            switch (lhs, rhs) {
            case (.architect, .architect), (.engineer, .engineer), (.none, .none):
                return true
            case let (.custom(name1), .custom(name2)):
                return name1 == name2
            default:
                return false
            }
        }
    }
    
    // Define CustomRole as a nested type
    struct CustomRole: Identifiable {
        let id = UUID()
        let name: String
        let prompt: String
    }
    
    init() {
        // loadSampleFileTree() // commented out as per plan
    }
    
    func loadSampleFileTree() {
        let rootPath = "/SamplePath/RepoMax"
        fileTree = [
            FileItem(name: "RepoMax", path: rootPath, type: .folder, isExpanded: true, isSelected: true, children: [
                FileItem(name: ".build", path: "\(rootPath)/.build", type: .folder, isSelected: true),
                FileItem(name: "Assets.xcassets", path: "\(rootPath)/Assets.xcassets", type: .folder, isSelected: true),
                FileItem(name: "Core", path: "\(rootPath)/Core", type: .folder),
                FileItem(name: "Features", path: "\(rootPath)/Features", type: .folder),
                FileItem(name: "UI", path: "\(rootPath)/UI", type: .folder),
                FileItem(name: "ViewModels", path: "\(rootPath)/ViewModels", type: .folder, isSelected: true),
                FileItem(name: "Views", path: "\(rootPath)/Views", type: .folder, isExpanded: true),
                FileItem(name: "AppState.swift", path: "\(rootPath)/AppState.swift", type: .file),
                FileItem(name: "ARCHITECTURE.md", path: "\(rootPath)/ARCHITECTURE.md", type: .file),
                FileItem(name: "Info.plist", path: "\(rootPath)/Info.plist", type: .file, isSelected: true),
                FileItem(name: "RepoMax.entitlements", path: "\(rootPath)/RepoMax.entitlements", type: .file, isSelected: true),
                FileItem(name: "RepoMaxApp.swift", path: "\(rootPath)/RepoMaxApp.swift", type: .file, isSelected: true)
            ])
        ]
    }
    
    func createNewProject() {
        // Implementation for creating a new project
    }
    
    func toggleFileSelection(path: String) {
        var isDir: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        
        if fileExists && isDir.boolValue {
            // For folders, toggle selection for all contained files
            let isSelected = isPathSelected(path)
            
            if isSelected {
                // Deselect all files in the folder
                removeFilesInFolder(path)
            } else {
                // Add all files in the folder recursively
                addFilesInFolder(path)
            }
            
            // Update UI state in the tree
            updateFileTreeSelection(path: path, isSelected: !isSelected)
        } else {
            // For regular files or sample data
            if selectedFiles.contains(path) {
                selectedFiles.remove(path)
            } else {
                selectedFiles.insert(path)
            }
        }
    }
    
    // Check if a path or any of its children are selected
    func isPathSelected(_ path: String) -> Bool {
        // If the exact path is selected
        if selectedFiles.contains(path) {
            return true
        }
        
        // Check if any child path is selected
        return selectedFiles.contains { $0.hasPrefix(path + "/") }
    }
    
    // Recursively add all files in a folder
    private func addFilesInFolder(_ folderPath: String) {
        // Skip if ignored
        if let parser = gitignoreParser, let base = workspaceBasePath, parser.isIgnored(filePath: folderPath, relativeTo: base) {
            return
        }
        // Add the folder itself to selection
        selectedFiles.insert(folderPath)
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
            for item in contents {
                let itemPath = (folderPath as NSString).appendingPathComponent(item)
                // Skip ignored items
                if let parser = gitignoreParser, let base = workspaceBasePath, parser.isIgnored(filePath: itemPath, relativeTo: base) {
                    continue
                }
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: itemPath, isDirectory: &isDir) {
                    if isDir.boolValue {
                        addFilesInFolder(itemPath)
                    } else {
                        selectedFiles.insert(itemPath)
                    }
                }
            }
        } catch {
            print("Error adding files in folder \(folderPath): \(error)")
        }
    }
    
    // Remove all files in a folder from selection
    private func removeFilesInFolder(_ folderPath: String) {
        selectedFiles = selectedFiles.filter { !$0.hasPrefix(folderPath + "/") && $0 != folderPath }
    }
    
    // Update the selection state in the file tree UI
    private func updateFileTreeSelection(path: String, isSelected: Bool) {
        // Function to recursively update selection state
        func updateSelection(in items: inout [FileItem], path: String, isSelected: Bool) -> Bool {
            for index in items.indices {
                if items[index].path == path {
                    items[index].isSelected = isSelected
                    
                    // Update all children if this is a folder
                    if items[index].type == .folder {
                        for i in items[index].children.indices {
                            items[index].children[i].isSelected = isSelected
                            // Recursively update for nested folders
                            if items[index].children[i].type == .folder {
                                _ = updateAllChildren(in: &items[index].children[i].children, isSelected: isSelected)
                            }
                        }
                    }
                    return true
                }
                
                if !items[index].children.isEmpty {
                    var children = items[index].children
                    if updateSelection(in: &children, path: path, isSelected: isSelected) {
                        items[index].children = children
                        return true
                    }
                }
            }
            return false
        }
        
        // Helper to update all children recursively
        func updateAllChildren(in items: inout [FileItem], isSelected: Bool) -> Bool {
            for index in items.indices {
                items[index].isSelected = isSelected
                if !items[index].children.isEmpty {
                    _ = updateAllChildren(in: &items[index].children, isSelected: isSelected)
                }
            }
            return true
        }
        
        var tree = fileTree
        if updateSelection(in: &tree, path: path, isSelected: isSelected) {
            fileTree = tree
        }
    }
    
    func copyWithDiffEditPrompt() {
        // Implementation for copying with diff edit prompt
    }
    
    func mergeChanges() {
        // Implementation for merging changes
    }
    
    @MainActor
    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            // Update current workspace
            currentWorkspacePath = url.path
            loadWorkspace(at: url.path)
            
            // Add to recent workspaces (avoid duplicates)
            if !recentWorkspaces.contains(url.path) {
                recentWorkspaces.append(url.path)
            }
        }
    }
    
    func loadWorkspace(at path: String) {
        fileTree.removeAll()
        selectedFiles.removeAll()
        currentWorkspacePath = path
        workspaceBasePath = path
        // Build and store gitignore parser
        let combinedIgnoreContent = buildCombinedIgnorePatterns(workspacePath: path)
        let parser = GitignoreParser(gitignoreContent: combinedIgnoreContent)
        gitignoreParser = parser
        // Initialize root item without children
        let rootDirName = URL(fileURLWithPath: path).lastPathComponent
        let rootItem = FileItem(
            name: rootDirName,
            path: path,
            type: .folder,
            isExpanded: true,
            isSelected: isPathSelected(path),
            children: []
        )
        fileTree = [rootItem]
        // Load children off the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            let children = self.loadDirectory(at: path, withGitignore: parser, basePath: path)
            DispatchQueue.main.async {
                self.updateChildrenInTree(id: rootItem.id, children: children)
            }
        }
    }
    
    private func buildCombinedIgnorePatterns(workspacePath: String) -> String {
        var combinedPatterns: [String] = []
        
        // 1. Start with global virtual gitignore patterns
        let globalPatterns = virtualGitignore.isEmpty ? 
            (UserDefaults.standard.string(forKey: "virtualGitignore") ?? "") : 
            virtualGitignore
            
        if !globalPatterns.isEmpty {
            combinedPatterns.append("# Global virtual gitignore patterns")
            combinedPatterns.append(globalPatterns)
        }
        
        // 2. Add standard .gitignore if it exists
        let gitignoreURL = URL(fileURLWithPath: workspacePath).appendingPathComponent(".gitignore")
        if FileManager.default.fileExists(atPath: gitignoreURL.path),
           let gitignoreContent = try? String(contentsOf: gitignoreURL, encoding: .utf8) {
            combinedPatterns.append("# Standard .gitignore patterns")
            combinedPatterns.append(gitignoreContent)
        }
        
        // 3. Add local .repo_ignore if it exists (takes precedence)
        let repoIgnoreURL = URL(fileURLWithPath: workspacePath).appendingPathComponent(".repo_ignore")
        if FileManager.default.fileExists(atPath: repoIgnoreURL.path),
           let repoIgnoreContent = try? String(contentsOf: repoIgnoreURL, encoding: .utf8) {
            combinedPatterns.append("# Local .repo_ignore patterns (override global)")
            combinedPatterns.append(repoIgnoreContent)
        }
        
        return combinedPatterns.joined(separator: "\n\n")
    }

    private func loadDirectory(at path: String, withGitignore gitignoreParser: GitignoreParser, basePath: String) -> [FileItem] {
        var items: [FileItem] = []
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: path)
            
            for name in directoryContents {
                // Default filter for dot files (except .repo_ignore which we want to show)
                if name.hasPrefix(".") && name != ".repo_ignore" {
                    continue
                }
                
                let filePath = (path as NSString).appendingPathComponent(name)
                
                // Filter out ignored files using improved parser
                if gitignoreParser.isIgnored(filePath: filePath, relativeTo: basePath) {
                    continue
                }
                
                // Check if folder or file
                var isDir: ObjCBool = false
                FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
                
                // For directories, recursively load children
                var children: [FileItem] = []
                if isDir.boolValue {
                    children = loadDirectory(at: filePath, withGitignore: gitignoreParser, basePath: basePath)
                }
                
                let item = FileItem(
                    name: name,
                    path: filePath,
                    type: isDir.boolValue ? .folder : .file,
                    isExpanded: false,
                    isSelected: false,
                    children: children
                )
                
                items.append(item)
            }
            
            // Sort folders first, then by name
            items.sort { (item1, item2) -> Bool in
                if item1.type == item2.type {
                    return item1.name < item2.name
                } else {
                    return item1.type == .folder
                }
            }
            
        } catch {
            print("Error reading directory \(path): \(error)")
        }
        
        return items
    }
    
    func clearLoadedFiles() {
        fileTree.removeAll()
        selectedFiles.removeAll()
        // Keep recentWorkspaces intact
    }
    
    func applyVirtualGitignore(_ patterns: String) {
        virtualGitignore = patterns
        // Re-filter the file list based on these new patterns
        if let path = currentWorkspacePath {
            loadWorkspace(at: path)
        }
    }
    
    // Sort files in the file tree by the given criterion
    func sortFiles(by criterion: String) {
        // Helper function to recursively sort items
        func sortItems(items: inout [FileItem], by criterion: String) {
            switch criterion {
            case "Name":
                items.sort { (item1, item2) -> Bool in
                    // Always put folders first, then sort by name
                    if item1.type != item2.type {
                        return item1.type == .folder
                    } else {
                        return item1.name.localizedStandardCompare(item2.name) == .orderedAscending
                    }
                }
            case "Size":
                items.sort { (item1, item2) -> Bool in
                    if item1.type != item2.type {
                        return item1.type == .folder
                    } else if item1.type == .file && item2.type == .file {
                        let size1 = calculateTokenCount(item1.path)
                        let size2 = calculateTokenCount(item2.path)
                        return size1 < size2
                    } else {
                        return item1.name.localizedStandardCompare(item2.name) == .orderedAscending
                    }
                }
            default:
                break
            }
            
            // Sort children recursively
            for index in items.indices where items[index].type == .folder {
                var children = items[index].children
                sortItems(items: &children, by: criterion)
                items[index].children = children
            }
        }
        
        // Sort the main tree
        var tree = fileTree
        sortItems(items: &tree, by: criterion)
        fileTree = tree
    }
    
    func calculateTokenCount(_ filePath: String) -> Int {
        // Example approximation
        guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else { return 0 }
        return content.count / 4
    }
    
    // Architect prompt template
    let architectPromptTemplate = """
    You are a senior software architect specializing in code design and implementation planning. Your role is to:
    1. Analyze the requested changes and break them down into clear, actionable steps
    2. Create a detailed implementation plan that includes:
       - Files that need to be modified
       - Specific code sections requiring changes
       - New functions, methods, or classes to be added
       - Dependencies or imports to be updated
       - Data structure modifications
       - Interface changes
       - Configuration updates

    For each change:
    - Describe the exact location in the code where changes are needed
    - Explain the logic and reasoning behind each modification
    - Provide example signatures, parameters, and return types
    - Note any potential side effects or impacts on other parts of the codebase
    - Highlight critical architectural decisions that need to be made

    You may include short code snippets to illustrate specific patterns, signatures, or structures, but do not implement the full solution.

    Focus solely on the technical implementation plan - exclude testing, validation, and deployment considerations unless they directly impact the architecture.
    """
    
    // Engineer prompt template
    let engineerPromptTemplate = """
    You are a senior software engineer whose role is to provide clear, actionable code changes. For each edit required:
    
    1. Specify locations and changes:
       - File path/name
       - Function/class being modified
       - The type of change (add/modify/remove)
    
    2. Show complete code for:
    """
    
    func useArchitectPrompt() {
        instructionsText = "I need architectural guidance for the following code:"
    }
    
    func useEngineerPrompt() {
        instructionsText = "I need engineering implementation for the following code:"
    }
    
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func copyFormattedContentToClipboard() {
        var textToCopy = ""
        
        // Follow the recommended order from prompts.md:
        // 1. File Map Block
        // 2. File Contents Block
        // 3. User Instructions Block
        // 4. Role-based Prompt Block
        // 5. XML Output Block
        
        // 1. Add file map if enabled
        if clipboardSettings.includeCodeMap {
            textToCopy += "<file_map>\n"
            if let workspacePath = currentWorkspacePath {
                textToCopy += workspacePath + "\n"
                
                // Create a tree structure from the selected files
                let fileStructure = createFileTreeStructure(from: selectedFiles, basePath: workspacePath)
                textToCopy += fileStructure
            } else {
                // If no workspace path, just list files
                for filePath in selectedFiles.sorted() {
                    textToCopy += "- \(filePath)\n"
                }
            }
            textToCopy += "</file_map>\n\n"
        }
        
        // 2. Add file contents if enabled
        if clipboardSettings.includeFiles && !selectedFiles.isEmpty {
            textToCopy += "<file_contents>\n"
            
            // Sort files for consistent output
            let sortedFiles = selectedFiles.sorted()
            
            for filePath in sortedFiles {
                if let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
                    // Get relative path if workspace path is available
                    let displayPath = currentWorkspacePath != nil ? 
                        filePath.replacingOccurrences(of: currentWorkspacePath!, with: "") : 
                        filePath
                    
                    textToCopy += "File: \(displayPath)\n"
                    
                    // Determine the file extension for proper syntax highlighting
                    let fileExtension = URL(fileURLWithPath: filePath).pathExtension
                    textToCopy += "```\(fileExtension)\n"
                    textToCopy += content + "\n"
                    textToCopy += "```\n\n"
                }
            }
            textToCopy += "</file_contents>\n\n"
        }
        
        // 3. Add user instructions if enabled
        if clipboardSettings.includeInstructions && !instructionsText.isEmpty {
            textToCopy += "<user_instructions>\n"
            textToCopy += instructionsText
            textToCopy += "\n</user_instructions>\n\n"
        }
        
        // 4. Add prompt based on current role
        switch currentRole {
        case .architect:
            textToCopy += architectPromptTemplate
            textToCopy += "\n\n"
        case .engineer:
            textToCopy += engineerPromptTemplate
            textToCopy += "\n\n"
        case .custom(let name):
            if let customRole = customRoles.first(where: { $0.name == name }) {
                textToCopy += "<meta prompt 1 = \"Custom\">\n"
                textToCopy += customRole.prompt
                textToCopy += "\n</meta prompt 1>\n\n"
            }
        case .none:
            // No prompt to add
            break
        }
        
        // 5. Add XML formatting instructions if needed (only if not .none)
        switch formatOption {
        case .diff:
            textToCopy += """
            <xml_formatting_instructions>
            ### Role
            - You are a code editing assistant: You can fulfill edit requests and chat with the user about code or other questions. Provide complete instructions or code lines when replying with xml formatting.
            
            ### Capabilities
            - Can create new files.
            - Can rewrite entire files.
            - Can perform partial search/replace modifications.
            - Can delete existing files.
            
            Avoid placeholders like `...` or // existing code here. Provide complete lines or code.
            
            ## Tools & Actions
            1. create – Create a new file if it doesn't exist.
            2. rewrite – Replace the entire content of an existing file.
            3. modify (search/replace) – For partial edits with <search> + <content>.
            4. delete – Remove a file entirely (empty <content>).
            
            ### Format to Follow for Repo Prompt's Diff Protocol
            
            <Plan>
            Describe your approach or reasoning here.
            </Plan>
            
            <file path="path/to/example.swift" action="modify">
              <change>
                <description>Brief explanation of this specific change</description>
                <search>
            ===
            [Exact original code block]
            ===
                </search>
                <content>
            ===
            [New or updated code block]
            ===
                </content>
              </change>
            </file>
            
            #### Tools Demonstration
            1. <file path="NewFile.swift" action="create"> – Full file in <content>
            2. <file path="DeleteMe.swift" action="delete"> – Empty <content>
            3. <file path="ModifyMe.swift" action="modify"> – Partial edit with <search> + <content>
            4. <file path="RewriteMe.swift" action="rewrite"> – Entire file in <content>
            </xml_formatting_instructions>
            """
        case .whole:
            textToCopy += """
            <xml_formatting_instructions>
            ### Role
            - You are a code editing assistant: You can fulfill edit requests and chat with the user about code or other questions. Provide complete instructions or code lines when replying with xml formatting.
            
            ### Capabilities
            - Can create new files.
            - Can rewrite entire files.
            - Can delete existing files.
            
            Avoid placeholders like `...` or // existing code here. Provide complete lines or code.
            
            ## Tools & Actions
            1. create – Create a new file if it doesn't exist.
            2. rewrite – Replace the entire content of an existing file.
            3. delete – Remove a file entirely (empty <content>).
            
            ### Format to Follow for Repo Prompt's Whole Protocol
            
            <Plan>
            Describe your approach or reasoning here.
            </Plan>
            
            <file path="path/to/example.swift" action="rewrite">
              <change>
                <description>Full file rewrite to update entire content</description>
                <content>
            ===
            [Complete new file content here]
            ===
                </content>
              </change>
            </file>
            
            #### Tools Demonstration
            1. <file path="NewFile.swift" action="create"> – Full file in <content>
            2. <file path="DeleteMe.swift" action="delete"> – Empty <content>
            3. <file path="RewriteMe.swift" action="rewrite"> – Entire file in <content>
            </xml_formatting_instructions>
            """
        case .none:
            // No XML formatting
            break
        }
        
        copyToClipboard(textToCopy)
    }
    
    // Parse the AI response to identify changes
    func applyChanges() {
        // Clear any previous pending changes
        pendingChanges.removeAll()
        backupContents.removeAll()
        
        if aiResponseText.contains("<file") {
            // Handle XML format
            parseXMLChanges()
        } else {
            // Handle engineer format
            parseEngineerFormatChanges()
        }
        
        // Show merge modal if we found changes
        if !pendingChanges.isEmpty {
            showMergeModal = true
        }
    }
    
    // Parse XML formatted changes, e.g., <file path="path/to/file.swift" action="modify">...</file>
    private func parseXMLChanges() {
        // First try to find file tags with their changes
        let pattern = #"<file\s+path="([^"]+)"\s+action="([^"]+)"[^>]*>.*?<content>===\n?([\s\S]*?)===\n?</content>.*?</file>"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = aiResponseText as NSString
            let matches = regex.matches(in: aiResponseText, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges >= 4 {
                    let pathRange = match.range(at: 1)
                    let actionRange = match.range(at: 2)
                    let contentRange = match.range(at: 3)
                    
                    let path = nsString.substring(with: pathRange)
                    let action = nsString.substring(with: actionRange)
                    let newContent = nsString.substring(with: contentRange)
                    
                    // Check if file exists to determine change type
                    var changeType = FileChange.ChangeType.create
                    var originalContent = ""
                    
                    if FileManager.default.fileExists(atPath: path) {
                        changeType = action.lowercased() == "modify" ? .modify : .rewrite
                        originalContent = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
                        
                        // If the file exists, back it up
                        backupContents[path] = originalContent
                    }
                    
                    // Add to pending changes
                    let fileChange = FileChange(
                        filePath: path,
                        originalContent: originalContent,
                        newContent: newContent,
                        changeType: changeType
                    )
                    
                    pendingChanges.append(fileChange)
                }
            }
            
            // If we found any changes, show the merge modal
            if !pendingChanges.isEmpty {
                showMergeModal = true
            }
        } catch {
            print("Error parsing XML: \(error)")
        }
    }
    
    // Parse engineer format changes - more complex, with "File:" and "Change:" markers
    private func parseEngineerFormatChanges() {
        let filePattern = #"File:\s*(.*?)\nChange:(.*?)(?=File:|$)"#
        
        do {
            let regex = try NSRegularExpression(pattern: filePattern, options: [.dotMatchesLineSeparators])
            let nsString = aiResponseText as NSString
            let matches = regex.matches(in: aiResponseText, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges >= 3 {
                    let pathRange = match.range(at: 1)
                    let changeRange = match.range(at: 2)
                    
                    let path = nsString.substring(with: pathRange).trimmingCharacters(in: .whitespacesAndNewlines)
                    let changeDescription = nsString.substring(with: changeRange)
                    
                    // Parse code blocks - this is more complex and depends on the format
                    // For now we'll just extract everything after the "Change:" marker
                    let newContent = extractCodeFromChangeDescription(changeDescription)
                    
                    // Check if file exists to determine change type
                    var changeType = FileChange.ChangeType.create
                    var originalContent = ""
                    
                    if FileManager.default.fileExists(atPath: path) {
                        changeType = .modify
                        originalContent = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
                        
                        // If the file exists, back it up
                        backupContents[path] = originalContent
                    }
                    
                    // Add to pending changes
                    let fileChange = FileChange(
                        filePath: path,
                        originalContent: originalContent,
                        newContent: newContent,
                        changeType: changeType
                    )
                    
                    pendingChanges.append(fileChange)
                }
            }
        } catch {
            print("Error parsing engineer format: \(error)")
        }
    }
    
    // Helper to extract code from change description
    private func extractCodeFromChangeDescription(_ description: String) -> String {
        // Look for ```swift or ``` code blocks
        let codeBlockPattern = #"```(?:swift|kotlin|java|python|javascript|typescript|go|ruby|rust|cpp|c|csharp|cs)?\n([\s\S]*?)```"#
        
        do {
            let regex = try NSRegularExpression(pattern: codeBlockPattern, options: [])
            let nsString = description as NSString
            let matches = regex.matches(in: description, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if let match = matches.first, match.numberOfRanges >= 2 {
                return nsString.substring(with: match.range(at: 1))
            }
        } catch {
            print("Error extracting code: \(error)")
        }
        
        // If no code block is found, just return the whole description as content
        return description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func undoChanges() {
        for (path, originalContent) in backupContents {
            try? originalContent.write(toFile: path, atomically: true, encoding: .utf8)
        }
        backupContents.removeAll()
        pendingChanges.removeAll()
    }
    
    // Toggle the applied state of a specific file change
    func toggleFileChange(id: UUID) {
        if let index = pendingChanges.firstIndex(where: { $0.id == id }) {
            pendingChanges[index].isApplied.toggle()
            
            // If toggling on, apply the change to the file
            if pendingChanges[index].isApplied {
                applyFileChange(pendingChanges[index])
            } else {
                // If toggling off, revert to the original content
                revertFileChange(pendingChanges[index])
            }
        }
    }
    
    // Apply a specific file change to the file system
    private func applyFileChange(_ change: FileChange) {
        let fileManager = FileManager.default
        let directory = URL(fileURLWithPath: change.filePath).deletingLastPathComponent().path
        
        // Ensure directory exists for new files
        if change.changeType == .create && !fileManager.fileExists(atPath: directory) {
            try? fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Write the new content to the file
        do {
            try change.newContent.write(toFile: change.filePath, atomically: true, encoding: .utf8)
            print("Applied change to \(change.filePath)")
        } catch {
            print("Error applying change to \(change.filePath): \(error)")
        }
    }
    
    // Revert a specific file change
    private func revertFileChange(_ change: FileChange) {
        if change.changeType == .create {
            // For new files, delete the file
            try? FileManager.default.removeItem(atPath: change.filePath)
        } else {
            // For modified files, revert to original content
            try? change.originalContent.write(toFile: change.filePath, atomically: true, encoding: .utf8)
        }
    }
    
    // Apply all changes that are marked as applied
    func finalizePendingChanges() {
        for change in pendingChanges where change.isApplied {
            applyFileChange(change)
        }
        
        // Clear the pending changes after applying
        pendingChanges.removeAll()
        showMergeModal = false
    }
    
    func addCustomRole(name: String, prompt: String) {
        let newRole = CustomRole(name: name, prompt: prompt)
        customRoles.append(newRole)
        // Set the current role to the new custom role
        currentRole = .custom(name)
    }
    
    // Helper function to create a tree structure representation of files
    private func createFileTreeStructure(from files: Set<String>, basePath: String) -> String {
        // Create a dictionary to represent the file tree
        var fileTree: [String: [String]] = [:]
        
        // Sort files for consistent output
        let sortedFiles = files.sorted()
        
        // Group files by directory
        for filePath in sortedFiles {
            let relativePath = filePath.replacingOccurrences(of: basePath, with: "")
            let components = relativePath.split(separator: "/").map(String.init)
            
            if components.count > 1 {
                // This is a file in a subdirectory
                let directory = "/" + components[0]
                if fileTree[directory] == nil {
                    fileTree[directory] = []
                }
                fileTree[directory]?.append(relativePath)
            } else {
                // This is a file in the root directory
                if fileTree["/"] == nil {
                    fileTree["/"] = []
                }
                fileTree["/"]?.append(relativePath)
            }
        }
        
        // Generate the tree representation
        var result = ""
        let sortedDirs = fileTree.keys.sorted()
        
        for (index, dir) in sortedDirs.enumerated() {
            let isLast = index == sortedDirs.count - 1
            
            if dir == "/" {
                // Files in root directory
                for (fileIndex, file) in (fileTree[dir] ?? []).enumerated() {
                    let fileIsLast = fileIndex == (fileTree[dir]?.count ?? 0) - 1
                    result += fileIsLast ? "└── \(file)\n" : "├── \(file)\n"
                }
            } else {
                // Subdirectory
                result += isLast ? "└── \(dir.dropFirst())\n" : "├── \(dir.dropFirst())\n"
                
                // Files in this subdirectory
                for (fileIndex, file) in (fileTree[dir] ?? []).sorted().enumerated() {
                    let fileComponents = file.split(separator: "/").map(String.init)
                    let fileName = fileComponents.dropFirst().joined(separator: "/")
                    let fileIsLast = fileIndex == (fileTree[dir]?.count ?? 0) - 1
                    
                    let prefix = isLast ? "    " : "│   "
                    result += prefix + (fileIsLast ? "└── " : "├── ") + fileName + "\n"
                }
            }
        }
        
        return result
    }
    
    // Filter file tree based on search text
    func filteredFileTree() -> [FileItem] {
        if searchText.isEmpty {
            return fileTree
        }
        
        // Helper function to filter items and their children
        func filterItems(_ items: [FileItem]) -> [FileItem] {
            var filteredItems: [FileItem] = []
            
            for item in items {
                // Check if the current item matches the search
                let nameMatches = item.name.lowercased().contains(searchText.lowercased())
                
                // Filter children
                let filteredChildren = filterItems(item.children)
                
                // Include the item if its name matches or if it has matching children
                if nameMatches || !filteredChildren.isEmpty {
                    var newItem = item
                    newItem.children = filteredChildren
                    
                    // If there are matches in children, expand the folder to show them
                    if !filteredChildren.isEmpty && item.type == .folder {
                        newItem.isExpanded = true
                    }
                    
                    filteredItems.append(newItem)
                }
            }
            
            return filteredItems
        }
        
        return filterItems(fileTree)
    }
    
    // Add lazy-loading and updateChildrenInTree helpers
    func loadChildrenIfNeeded(for item: FileItem) {
        guard item.type == .folder, item.children.isEmpty, let base = workspaceBasePath, let parser = gitignoreParser else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            let children = self.loadDirectory(at: item.path, withGitignore: parser, basePath: base)
            DispatchQueue.main.async {
                self.updateChildrenInTree(id: item.id, children: children)
            }
        }
    }

    private func updateChildrenInTree(id: UUID, children: [FileItem]) {
        func update(in items: inout [FileItem]) -> Bool {
            for index in items.indices {
                if items[index].id == id {
                    items[index].children = children
                    return true
                }
                if !items[index].children.isEmpty {
                    if update(in: &items[index].children) {
                        return true
                    }
                }
            }
            return false
        }
        var tree = fileTree
        if update(in: &tree) {
            fileTree = tree
        }
    }
}

struct FileItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var path: String
    var type: FileType
    var isExpanded: Bool = false
    var isSelected: Bool = false
    var children: [FileItem] = []
    
    enum FileType {
        case file, folder
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct ClipboardSettings {
    var includeFiles: Bool = true
    var includeInstructions: Bool = true
    var includeCodeMap: Bool = false
}

struct FileChange: Identifiable {
    var id = UUID()
    var filePath: String
    var originalContent: String
    var newContent: String
    var changeType: ChangeType
    var isApplied: Bool = false
    
    enum ChangeType: String {
        case create = "Create"
        case modify = "Change"
        case delete = "Delete"
        case rewrite = "Rewrite"
    }
    
    var fileName: String {
        URL(fileURLWithPath: filePath).lastPathComponent
    }
}