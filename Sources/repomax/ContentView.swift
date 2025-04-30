import SwiftUI
import AppKit

@available(macOS 10.15, *)
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showFileTreeOptions: Bool = false
    @State private var showFormatSettings: Bool = false
    @State private var showClipboardSettings: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Left sidebar with file explorer
            SidebarView()
                .frame(width: 250)
            
            // Main content area
            VStack(spacing: 0) {
                // Top navigation tabs
                TabBarView()
                
                // Main content based on selected tab
                if appState.selectedTab == .apply {
                    ApplyView()
                } else {
                    ComposeView()
                }
            }
        }
        .sheet(isPresented: $appState.showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $appState.showRolePrompt) {
            RolePromptView()
        }
        .sheet(isPresented: $appState.showMergeModal) {
            MergeModalView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $appState.showRolePromptSelector) {
            RolePromptSelectorView()
                .environmentObject(appState)
        }
    }
}

struct TabBarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 0) {
            // Compose button
            Button {
                appState.selectedTab = .compose
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                    Text("Compose")
                        .font(.system(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .buttonStyle(.plain)
            .background(appState.selectedTab == .compose ? Color.gray.opacity(0.2) : Color.clear)
            .overlay(
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 2)
                    .offset(y: 25)
                    .opacity(appState.selectedTab == .compose ? 1 : 0)
            )
            
            // Apply button
            Button {
                appState.selectedTab = .apply
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16))
                    Text("Apply")
                        .font(.system(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .buttonStyle(.plain)
            .background(appState.selectedTab == .apply ? Color.yellow.opacity(0.2) : Color.clear)
            .overlay(
                Rectangle()
                    .fill(Color.yellow)
                    .frame(height: 2)
                    .offset(y: 25)
                    .opacity(appState.selectedTab == .apply ? 1 : 0)
            )
            
            // Settings button
            Button {
                appState.showSettings.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 16))
                    .frame(width: 50, height: 50)
            }
            .buttonStyle(.plain)
            .background(Color.clear)
        }
        .padding(.top, 8)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }
}

@available(macOS 10.15, *)
struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @State private var showContextMenu = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search files", text: $appState.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !appState.searchText.isEmpty {
                    Button(action: {
                        appState.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
            .background(Color(NSColor.textBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            
            // Toolbar
            HStack(spacing: 16) {
                // Hamburger menu for .gitignore editing
                Menu {
                    Button("Edit .gitignore") {
                        appState.showIgnorePatterns = true
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title3)
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .frame(width: 36, height: 36)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 4)
                
                Button {
                    // Open folder action
                    appState.openFolder()
                } label: {
                    Text("Open Folder")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .frame(width: 90, height: 36)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 4)
                
                Button {
                    // Clear
                    appState.clearLoadedFiles()
                } label: {
                    Text("Clear")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .frame(width: 60, height: 36)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 4)
                
                Button {
                    // Refresh
                    if let path = appState.currentWorkspacePath {
                        appState.loadWorkspace(at: path)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .frame(width: 36, height: 36)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
            
            // Recent Workspaces (if any)
            if !appState.recentWorkspaces.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Workspaces")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    
                    ForEach(appState.recentWorkspaces, id: \.self) { workspacePath in
                        Button {
                            appState.loadWorkspace(at: workspacePath)
                            appState.currentWorkspacePath = workspacePath
                        } label: {
                            Text(URL(fileURLWithPath: workspacePath).lastPathComponent)
                                .font(.system(size: 14))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(4)
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.bottom, 12)
            }
            
            // File tree with search results
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    let filteredTree = appState.filteredFileTree()
                    if filteredTree.isEmpty && !appState.searchText.isEmpty {
                        Text("No results found")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(filteredTree) { item in
                            FileTreeItemView(item: item, level: 0)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .background(Color(NSColor.windowBackgroundColor).opacity(0.9))
        .overlay(
            Divider(),
            alignment: .trailing
        )
        .contextMenu {
            Button("Add Folder") {}
            Menu("Sort") {
                Button("By Name") {}
                Button("By Type") {}
            }
        }
        .sheet(isPresented: $appState.showIgnorePatterns) {
            IgnorePatternsView()
                .environmentObject(appState)
        }
    }
}

@available(macOS 10.15, *)
struct FileTreeItemView: View {
    let item: FileItem
    let level: Int
    @EnvironmentObject var appState: AppState
    @State private var isItemExpanded: Bool
    @State private var isItemSelected: Bool
    
    init(item: FileItem, level: Int) {
        self.item = item
        self.level = level
        _isItemExpanded = State(initialValue: item.isExpanded)
        _isItemSelected = State(initialValue: item.isSelected)
    }
    
    // Helper to find the item in the file tree hierarchy
    private func updateItemInTree(expanded: Bool? = nil, selected: Bool? = nil) {
        // Function to recursively update an item in the tree
        func updateItem(in items: inout [FileItem], id: UUID, expanded: Bool?, selected: Bool?) -> Bool {
            for index in items.indices {
                if items[index].id == id {
                    if let expanded = expanded {
                        items[index].isExpanded = expanded
                    }
                    if let selected = selected {
                        items[index].isSelected = selected
                    }
                    return true
                }
                
                if !items[index].children.isEmpty {
                    var children = items[index].children
                    if updateItem(in: &children, id: id, expanded: expanded, selected: selected) {
                        items[index].children = children
                        return true
                    }
                }
            }
            return false
        }
        
        // Update the main file tree
        var tree = appState.fileTree
        if updateItem(in: &tree, id: item.id, expanded: expanded, selected: selected) {
            // This is a workaround to trigger UI update, as directly modifying fileTree may not always work
            // In a real app, you'd use a better state management approach
            DispatchQueue.main.async {
                appState.fileTree = tree
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                if item.type == .folder {
                    Image(systemName: isItemExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .frame(width: 12)
                        .opacity(item.children.isEmpty ? 0 : 1)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isItemExpanded.toggle()
                            updateItemInTree(expanded: isItemExpanded)
                        }
                } else {
                    Spacer()
                        .frame(width: 12)
                }
                
                CheckboxView(isChecked: isItemSelected || (item.type == .folder && appState.isPathSelected(item.path))) {
                    // Toggle selection on checkbox click
                    isItemSelected.toggle()
                    updateItemInTree(selected: isItemSelected)
                    
                    // Update the selected files set
                    appState.toggleFileSelection(path: item.path)
                    
                    // Update local state to match global state
                    DispatchQueue.main.async {
                        if item.type == .folder {
                            isItemSelected = appState.isPathSelected(item.path)
                        } else {
                            isItemSelected = appState.selectedFiles.contains(item.path)
                        }
                    }
                }
                .frame(width: 16, height: 16)
                
                Image(systemName: item.type == .folder ? "folder.fill" : "doc.fill")
                    .foregroundColor(item.type == .folder ? Color.yellow : Color.gray)
                
                Text(item.name)
                    .font(.system(size: 14))
                
                Spacer()
            }
            .padding(.vertical, 4)
            .padding(.leading, CGFloat(level * 16))
            .contentShape(Rectangle())
            .background(isItemSelected ? Color.blue.opacity(0.1) : Color.clear)
            .onTapGesture {
                if item.type == .folder {
                    isItemExpanded.toggle()
                    updateItemInTree(expanded: isItemExpanded)
                } else {
                    isItemSelected.toggle()
                    updateItemInTree(selected: isItemSelected)
                    appState.toggleFileSelection(path: item.path)
                }
            }
            
            if isItemExpanded && item.type == .folder {
                ForEach(item.children) { child in
                    FileTreeItemView(item: child, level: level + 1)
                }
            }
        }
    }
}

struct CheckboxView: View {
    let isChecked: Bool
    var onToggle: () -> Void = {}
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.gray, lineWidth: 1)
                .background(
                    isChecked ? 
                    RoundedRectangle(cornerRadius: 3).fill(Color.yellow) : 
                    RoundedRectangle(cornerRadius: 3).fill(Color.clear)
                )
                .frame(width: 16, height: 16)
            
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .onTapGesture {
            onToggle()
        }
    }
}

struct ApplyView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedContentTab = "Contents.json"
    @State private var isAnalyzing = false
    @State private var selectedFormatOption = "XML"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Apply AI Code Changes")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Paste AI response with code changes, then apply changes through the merge interface.")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                
                // AI Response section
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Response")
                        .font(.headline)
                    
                    TextEditor(text: $appState.aiResponseText)
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(4)
                        .overlay(
                            Text(selectedFormatOption == "XML" ? 
                                 "Paste AI response with XML-formatted changes here...\nExample: <file path=\"/path/to/file.swift\">file content</file>" :
                                 "Paste AI response with Engineer-formatted changes here...\nExample: File: /path/to/file.swift\nChange: Add new method")
                                    .foregroundColor(.gray)
                                    .padding(12)
                                    .opacity(appState.aiResponseText.isEmpty ? 1 : 0),
                            alignment: .topLeading
                        )
                        .frame(height: 300)
                    
                    HStack {
                        Spacer()
                        
                        // Show analyzing indicator
                        if isAnalyzing {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                
                                Text("Analyzing changes...")
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                        
                        Button {
                            appState.aiResponseText = ""
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Clear")
                            }
                            .font(.system(size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            // Start analyzing and then apply changes
                            isAnalyzing = true
                            
                            // Simulate delay for analysis
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                appState.applyChanges()
                                isAnalyzing = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up")
                                Text("Review & Apply Changes")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(appState.aiResponseText.isEmpty || isAnalyzing)
                        
                        Button {
                            appState.undoChanges()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.uturn.left")
                                Text("Undo All")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(appState.backupContents.isEmpty)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black.opacity(0.05))
                .cornerRadius(8)
                
                Divider()
                    .padding(.vertical)
                
                // How to use section
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to use Apply Mode")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("1. Paste AI response")
                                    .fontWeight(.semibold)
                                
                                Text("Paste the AI's response with XML or Engineer format in the AI Response box.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("2. Review changes")
                                    .fontWeight(.semibold)
                                
                                Text("Click \"Review & Apply Changes\" to see a list of all file changes before they're applied.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("3. Choose changes")
                                    .fontWeight(.semibold)
                                
                                Text("Toggle which changes to apply by clicking the checkboxes next to each file.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("4. Apply changes")
                                    .fontWeight(.semibold)
                                
                                Text("Click \"Apply Selected Changes\" to write the changes to disk. Use \"Undo All\" to revert if needed.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}

struct ComposeView: View {
    @EnvironmentObject var appState: AppState
    @State private var instructionsText = "" {
        didSet {
            appState.instructionsText = instructionsText
        }
    }
    @State private var showCodeMap = false
    @State private var showClipboardSettings = false
    
    // Computed property to get selected files with metadata
    var selectedFiles: [SelectedFile] {
        let totalTokens = getTotalTokens()
        
        return appState.selectedFiles.compactMap { path in
            let tokens = appState.calculateTokenCount(path)
            let percentage = totalTokens > 0 ? (Double(tokens) / Double(totalTokens)) * 100.0 : 0.0
            let size = formatTokenSize(tokens)
            let name = URL(fileURLWithPath: path).lastPathComponent
            
            return SelectedFile(path: path, name: name, size: size, percentage: percentage)
        }
    }
    
    // Helper method to get raw total tokens
    func getTotalTokens() -> Int {
        return appState.selectedFiles.reduce(0) { partial, path in
            partial + appState.calculateTokenCount(path)
        }
    }
    
    // Format tokens for display
    func formatTokenSize(_ tokens: Int) -> String {
        if tokens > 1000 {
            let kb = Double(tokens) / 1000.0
            return String(format: "~%.2fk", kb)
        } else {
            return "~\(tokens)"
        }
    }
    
    // Format total tokens for display
    func calculateTotalTokens() -> String {
        let totalTokens = getTotalTokens()
        return formatTokenSize(totalTokens)
    }
    
    // Calculate total tokens for copy including all components
    func calculateTotalForCopy() -> String {
        var totalTokens = 0
        
        // Add instructions tokens
        if appState.clipboardSettings.includeInstructions {
            totalTokens += appState.instructionsText.count / 4
        }
        
        // Add prompt tokens based on current role
        switch appState.currentRole {
        case .architect:
            totalTokens += appState.architectPromptTemplate.count / 4
        case .engineer:
            totalTokens += appState.engineerPromptTemplate.count / 4
        case .custom(let name):
            if let customRole = appState.customRoles.first(where: { $0.name == name }) {
                totalTokens += customRole.prompt.count / 4
            }
        case .none:
            break
        }
        
        // Add code map tokens
        if appState.clipboardSettings.includeCodeMap {
            totalTokens += appState.selectedFiles.count * 20 // Approximate for paths
        }
        
        // Add file content tokens
        if appState.clipboardSettings.includeFiles {
            totalTokens += getTotalTokens()
        }
        
        // Add XML formatting instructions (approximately)
        switch appState.formatOption {
        case .diff:
            totalTokens += 600 // Approximate token count for XML diff instructions
        case .whole:
            totalTokens += 500 // Approximate token count for XML whole instructions
        case .none:
            break
        }
        
        return formatTokenSize(totalTokens)
    }
    
    // Group files by their directory
    func groupFilesByDirectory() -> [String: [SelectedFile]] {
        var groupedFiles: [String: [SelectedFile]] = [:]
        
        for file in selectedFiles {
            let url = URL(fileURLWithPath: file.path)
            let directory = url.deletingLastPathComponent().path
            let displayDirectory = URL(fileURLWithPath: directory).lastPathComponent
            
            if groupedFiles[displayDirectory] == nil {
                groupedFiles[displayDirectory] = []
            }
            groupedFiles[displayDirectory]?.append(file)
        }
        
        // If no directory info is available, use "Files" as default category
        if groupedFiles.isEmpty && !selectedFiles.isEmpty {
            groupedFiles["Files"] = selectedFiles
        }
        
        return groupedFiles
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar with tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Code Map toggle
                    Button {
                        appState.clipboardSettings.includeCodeMap.toggle()
                    } label: {
                        HStack {
                            Text("Code Map")
                            Image(systemName: appState.clipboardSettings.includeCodeMap ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(appState.clipboardSettings.includeCodeMap ? .green : .gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    
                    // XML Format toggle
                    Button {
                        switch appState.formatOption {
                        case .none:
                            appState.formatOption = .diff
                        case .diff:
                            appState.formatOption = .whole
                        case .whole:
                            appState.formatOption = .none
                        }
                    } label: {
                        HStack {
                            Text("XML Format")
                            Image(systemName: getXMLFormatIcon())
                                .foregroundColor(getXMLFormatColor())
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    
                    // Architect toggle
                    Button {
                        if appState.currentRole == .architect {
                            appState.currentRole = .none
                        } else {
                            appState.currentRole = .architect
                        }
                    } label: {
                        HStack {
                            Text("Architect")
                            Image(systemName: appState.currentRole == .architect ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(appState.currentRole == .architect ? .green : .gray)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    
                    // Engineer toggle
                    Button {
                        if appState.currentRole == .engineer {
                            appState.currentRole = .none
                        } else {
                            appState.currentRole = .engineer
                        }
                    } label: {
                        HStack {
                            Text("Engineer")
                            Image(systemName: appState.currentRole == .engineer ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(appState.currentRole == .engineer ? .green : .gray)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    
                    // Custom prompts (if any)
                    ForEach(appState.customRoles) { role in
                        Button {
                            // Toggle custom role
                            if appState.currentRole == .custom(role.name) {
                                appState.currentRole = .none
                            } else {
                                appState.currentRole = .custom(role.name)
                            }
                        } label: {
                            HStack {
                                Text(role.name)
                                Image(systemName: appState.currentRole == .custom(role.name) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(appState.currentRole == .custom(role.name) ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    }
                    
                    // Add custom prompt button
                    Button {
                        appState.showRolePromptSelector = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Custom")
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.05))
            
            Divider()
            
            // Instructions section
            VStack(alignment: .leading, spacing: 8) {
                Text("Instructions")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                // Main text editor
                TextEditor(text: $instructionsText)
                    .font(.system(.body))
                    .frame(height: 100)
                    .padding()
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Selected files section
            VStack(spacing: 0) {
                HStack {
                    Text("Selected Files")
                        .font(.headline)
                    
                    Spacer()
                    
                    // File count and token count display
                    Text("\(appState.selectedFiles.count) files, \(calculateTotalTokens())")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    
                    Menu {
                        Button("Sort by Name") {
                            // Implement sorting by name
                        }
                        Button("Sort by Size") {
                            // Implement sorting by size
                        }
                    } label: {
                        HStack {
                            Text("Sort")
                            Image(systemName: "chevron.down")
                        }
                    }
                }
                .padding()
                
                Divider()
                
                // Scrollable file area
                ScrollView {
                    VStack(spacing: 12) {
                        if appState.fileViewMode == .folder {
                            // Directory view
                            ForEach(Array(groupFilesByDirectory().keys.sorted()), id: \.self) { directory in
                                if let files = groupFilesByDirectory()[directory] {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(directory)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                            .padding(.horizontal)
                                        
                                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                            ForEach(files) { file in
                                                FileItemView(file: file)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            // File list view
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(selectedFiles) { file in
                                    FileItemView(file: file)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
            }
            .background(Color.black.opacity(0.05))
            
            Divider()
                .padding(.vertical, 8)
            
            // Copy to clipboard section at the bottom
            VStack(spacing: 10) {
                HStack {
                    // Copy button
                    Button {
                        // Copy to clipboard action
                        appState.copyFormattedContentToClipboard()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy to Clipboard")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    // Clipboard settings button
                    Button {
                        showClipboardSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .padding(8)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Total token count for copy
                    HStack {
                        Text("Total: ")
                            .foregroundColor(.gray)
                        Text(calculateTotalForCopy())
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                
                // Selected components pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if appState.clipboardSettings.includeInstructions {
                            Pill(text: "Instructions", color: .blue)
                        }
                        
                        if appState.currentRole != .none {
                            Pill(text: "Role: \(appState.currentRole.displayName)", color: .purple)
                        }
                        
                        if appState.clipboardSettings.includeCodeMap {
                            Pill(text: "Code Map", color: .green)
                        }
                        
                        if appState.clipboardSettings.includeFiles {
                            Pill(text: "Files", color: .orange)
                        }
                        
                        if appState.formatOption != .none {
                            Pill(text: "XML Format: \(appState.formatOption == .diff ? "Diff" : "Whole")", color: .yellow)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color.black.opacity(0.05))
        }
        .sheet(isPresented: $showClipboardSettings) {
            ClipboardSettingsView()
                .environmentObject(appState)
        }
    }
    
    // Helper function for XML Format icon
    private func getXMLFormatIcon() -> String {
        switch appState.formatOption {
        case .none:
            return "circle"
        case .diff:
            return "checkmark.circle.fill"
        case .whole:
            return "checkmark.circle.fill"
        }
    }
    
    // Helper function for XML Format color
    private func getXMLFormatColor() -> Color {
        switch appState.formatOption {
        case .none:
            return .gray
        case .diff:
            return .blue
        case .whole:
            return .green
        }
    }
}

// Pill View for selected components
struct Pill: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(12)
    }
}

// Extension for AppState.Role to add displayName
extension AppState.Role {
    var displayName: String {
        switch self {
        case .architect:
            return "Architect"
        case .engineer:
            return "Engineer"
        case .custom(let name):
            return name
        case .none:
            return "None"
        }
    }
}

struct SelectedFile: Identifiable {
    let id: UUID
    let path: String
    let name: String
    let size: String
    let percentage: Double
    
    init(path: String, name: String, size: String, percentage: Double) {
        self.id = UUID()
        self.path = path
        self.name = name
        self.size = size
        self.percentage = percentage
    }
    
    // For backward compatibility with sample data
    init(name: String, size: String, percentage: Int) {
        self.id = UUID()
        self.path = ""
        self.name = name
        self.size = size
        self.percentage = Double(percentage)
    }
}

@available(macOS 10.15, *)
struct FileItemView: View {
    let file: SelectedFile
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc")
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.system(size: 14))
                    .lineLimit(1)
                
                HStack {
                    Text(file.size)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f%%", file.percentage))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    // Simple percentage indicator
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.green)
                            .frame(width: CGFloat(min(50 * (file.percentage / 100.0), 50)), height: 4)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("XML Format Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Format")
                    .font(.headline)
                
                HStack(spacing: 0) {
                    Button("Diff") {
                        appState.formatOption = .diff
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(appState.formatOption == .diff ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Button("Whole") {
                        appState.formatOption = .whole
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(appState.formatOption == .whole ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Text("Diff: Outputs only the specific changes needed. Requires a powerful model (e.g. Claude Sonnet).")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Whole: Outputs entire file contents with changes.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .padding(.vertical, 8)
                
            Text("When you choose XML Diff format:")
                .font(.headline)
                
            Text("1. Each file is wrapped in XML tags <file path=\"path/to/file.ext\">...")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                
            Text("2. The AI can easily parse these tags to understand file structure")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                
            Text("3. This format works best for code changes across multiple files")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Apply") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 400, height: 400)
    }
}

@available(macOS 10.15, *)
struct RolePromptView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if appState.currentRole == .architect {
                Text("[Architect]")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("You are a senior software architect specializing in code design and implementation planning. Your role is to:")
                    .padding(.bottom, 8)
                
                Text("1. Analyze the requested changes and break them down into clear, actionable steps")
                Text("2. Create a detailed implementation plan that includes:")
                Text("   - Files that need to be modified")
                Text("   - Specific code sections")
            } else if appState.currentRole == .engineer {
                Text("[Engineer]")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("You are a senior software engineer whose role is to provide clear, actionable code changes. For each edit required:")
                    .padding(.bottom, 8)
                
                Text("1. Specify locations and changes:")
                Text("   - File path/name")
                Text("   - Function/class being modified")
                Text("   - The type of change (add/modify/remove)")
                
                Text("2. Show complete code for:")
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}

// MARK: - View Extensions
extension View {
    // ... existing code ...
    
    // cornerRadius method - moved to ViewHelpers.swift
    
    // ... existing code ...
}

// The following definitions have been moved to ViewHelpers.swift
// ... existing code ...