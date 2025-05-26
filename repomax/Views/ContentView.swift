import SwiftUI
import AppKit

// MARK: - Visual Effect View for Glass Effect
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

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
                .frame(width: 280)
            
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
        .background(
            VisualEffectView(material: .windowBackground, blendingMode: .behindWindow)
        )
        .sheet(isPresented: $appState.showSettings) {
            ModernSettingsView()
                .environmentObject(appState)
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
                VStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 18, weight: .medium))
                    Text("Compose")
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(appState.selectedTab == .compose ? .primary : .secondary)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Group {
                    if appState.selectedTab == .compose {
                        VisualEffectView(material: .selection, blendingMode: .withinWindow)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Color.clear
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: appState.selectedTab)
            
            // Apply button
            Button {
                appState.selectedTab = .apply
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "arrow.up.square")
                        .font(.system(size: 18, weight: .medium))
                    Text("Apply")
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(appState.selectedTab == .apply ? .primary : .secondary)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Group {
                    if appState.selectedTab == .apply {
                        VisualEffectView(material: .selection, blendingMode: .withinWindow)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Color.clear
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: appState.selectedTab)
        }
        .frame(height: 60)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            VisualEffectView(material: .titlebar, blendingMode: .withinWindow)
        )
        .overlay(
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 0.5),
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
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))
                
                TextField("Search files", text: $appState.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                
                if !appState.searchText.isEmpty {
                    Button(action: {
                        appState.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                VisualEffectView(material: .menu, blendingMode: .withinWindow)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Toolbar
            HStack(spacing: 12) {
                // Hamburger menu for .gitignore editing
                Menu {
                    Button("Edit .gitignore") {
                        appState.showIgnorePatterns = true
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 15, weight: .medium))
                        .frame(width: 32, height: 32)
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .background(
                    VisualEffectView(material: .menu, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                )
                
                Button {
                    appState.openFolder()
                } label: {
                    Text("Open")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .frame(height: 32)
                .padding(.horizontal, 12)
                .background(
                    VisualEffectView(material: .menu, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                )
                
                Button {
                    appState.clearLoadedFiles()
                } label: {
                    Text("Clear")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .frame(height: 32)
                .padding(.horizontal, 12)
                .background(
                    VisualEffectView(material: .menu, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                )
                
                Button {
                    if let path = appState.currentWorkspacePath {
                        appState.loadWorkspace(at: path)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 15, weight: .medium))
                        .frame(width: 32, height: 32)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .background(
                    VisualEffectView(material: .menu, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Recent Workspaces
            if !appState.recentWorkspaces.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Workspaces")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    ForEach(appState.recentWorkspaces, id: \.self) { workspacePath in
                        Button {
                            appState.loadWorkspace(at: workspacePath)
                            appState.currentWorkspacePath = workspacePath
                        } label: {
                            Text(URL(fileURLWithPath: workspacePath).lastPathComponent)
                                .font(.system(size: 13))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .opacity(0.8)
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 16)
            }
            
            // File tree with search results
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    let filteredTree = appState.filteredFileTree()
                    if filteredTree.isEmpty && !appState.searchText.isEmpty {
                        Text("No results found")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                            .padding()
                    } else {
                        ForEach(filteredTree) { item in
                            FileTreeItemView(item: item, level: 0)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
        )
        .overlay(
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(width: 0.5),
            alignment: .trailing
        )
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
    @State private var isHovering: Bool = false
    
    init(item: FileItem, level: Int) {
        self.item = item
        self.level = level
    }
    
    // Helper to locate the up-to-date item in the fileTree by its ID
    private func findItem(in items: [FileItem], id: UUID) -> FileItem? {
        for file in items {
            if file.id == id { return file }
            if let found = findItem(in: file.children, id: id) {
                return found
            }
        }
        return nil
    }
    
    private var currentItem: FileItem? {
        // When searching, look in filtered tree; otherwise use main tree
        let searchTree = appState.searchText.isEmpty ? appState.fileTree : appState.filteredFileTree()
        return findItem(in: searchTree, id: item.id)
    }
    
    // Helper to find the item in the file tree hierarchy
    private func updateItemInTree(expanded: Bool? = nil) {
        // Function to recursively update an item in the tree
        func updateItem(in items: inout [FileItem], id: UUID, expanded: Bool?) -> Bool {
            for index in items.indices {
                if items[index].id == id {
                    if let expanded = expanded {
                        items[index].isExpanded = expanded
                    }
                    return true
                }
                if !items[index].children.isEmpty {
                    var children = items[index].children
                    if updateItem(in: &children, id: id, expanded: expanded) {
                        items[index].children = children
                        return true
                    }
                }
            }
            return false
        }
        
        // Update the main file tree (always update the source tree, not filtered)
        var tree = appState.fileTree
        if updateItem(in: &tree, id: item.id, expanded: expanded) {
            DispatchQueue.main.async {
                appState.fileTree = tree
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                // Indentation
                if level > 0 {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: CGFloat(level * 16))
                }
                
                // Expansion indicator for folders
                if item.type == .folder {
                    let isExpanded = currentItem?.isExpanded ?? false
                    Button {
                        appState.loadChildrenIfNeeded(for: item)
                        updateItemInTree(expanded: !isExpanded)
                    } label: {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 16, height: 16)
                            .opacity((currentItem?.children.isEmpty ?? true) ? 0.3 : 1.0)
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer().frame(width: 16)
                }
                
                // Checkbox
                let isChecked = appState.isPathSelected(item.path)
                CheckboxView(isChecked: isChecked) {
                    appState.toggleFileSelection(path: item.path)
                }
                .frame(width: 18, height: 18)
                
                // File/folder icon
                Image(systemName: item.type == .folder ? "folder.fill" : "doc.text.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(item.type == .folder ? .orange : .blue)
                    .frame(width: 16, height: 16)
                
                // File/folder name
                Text(item.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .background(
                Group {
                    if appState.isPathSelected(item.path) {
                        VisualEffectView(material: .selection, blendingMode: .withinWindow)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else if isHovering {
                        VisualEffectView(material: .menu, blendingMode: .withinWindow)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .opacity(0.5)
                    } else {
                        Color.clear
                    }
                }
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovering = hovering
                }
            }
            .onTapGesture {
                if item.type == .folder {
                    let isExpanded = currentItem?.isExpanded ?? false
                    appState.loadChildrenIfNeeded(for: item)
                    updateItemInTree(expanded: !isExpanded)
                } else {
                    appState.toggleFileSelection(path: item.path)
                }
            }
            
            // Children (if expanded)
            if currentItem?.isExpanded == true && item.type == .folder {
                ForEach(currentItem?.children ?? []) { child in
                    FileTreeItemView(item: child, level: level + 1)
                }
            }
        }
    }
}

struct CheckboxView: View {
    let isChecked: Bool
    var onToggle: () -> Void = {}
    @State private var isHovering: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(isChecked ? Color.accentColor : Color.secondary.opacity(0.6), lineWidth: 1.5)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isChecked ? Color.accentColor : Color.clear)
                )
                .frame(width: 16, height: 16)
                .scaleEffect(isHovering ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isHovering)
            
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onHover { hovering in
            isHovering = hovering
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
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Apply AI Code Changes")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Paste AI response with code changes, then apply changes through the merge interface.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    VisualEffectView(material: .headerView, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
                
                // AI Response section
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI Response")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    // Text editor container
                    ZStack(alignment: .topLeading) {
                        VisualEffectView(material: .menu, blendingMode: .withinWindow)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        TextEditor(text: $appState.aiResponseText)
                            .font(.system(.body, design: .monospaced))
                            .padding(16)
                            .background(Color.clear)
                            .scrollContentBackground(.hidden)
                        
                        if appState.aiResponseText.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Paste AI response with XML-formatted changes here...")
                                    .font(.system(.body))
                                    .foregroundColor(.secondary)
                                
                                Text("Example: <file path=\"/path/to/file.swift\">file content</file>")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary.opacity(0.8))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                        }
                    }
                    .frame(height: 240)
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Spacer()
                        
                        // Show analyzing indicator
                        if isAnalyzing {
                            HStack(spacing: 10) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                                
                                Text("Analyzing changes...")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            )
                        }
                        
                        Button {
                            appState.aiResponseText = ""
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Clear")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            )
                            .foregroundColor(.secondary)
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
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.square")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Review & Apply Changes")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            )
                            .foregroundColor(.green)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(appState.aiResponseText.isEmpty || isAnalyzing)
                        
                        Button {
                            appState.undoChanges()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.uturn.left")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Undo All")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            )
                            .foregroundColor(.red)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(appState.backupContents.isEmpty)
                    }
                }
                .padding(20)
                .background(
                    VisualEffectView(material: .contentBackground, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
                
                // How to use section
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to use Apply Mode")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top, spacing: 16) {
                            InstructionCard(
                                step: "1",
                                title: "Paste AI response",
                                description: "Paste the AI's response with XML or Engineer format in the AI Response box.",
                                color: .blue
                            )
                            
                            InstructionCard(
                                step: "2",
                                title: "Review changes",
                                description: "Click \"Review & Apply Changes\" to see a list of all file changes before they're applied.",
                                color: .green
                            )
                        }
                        
                        HStack(alignment: .top, spacing: 16) {
                            InstructionCard(
                                step: "3",
                                title: "Choose changes",
                                description: "Toggle which changes to apply by clicking the checkboxes next to each file.",
                                color: .orange
                            )
                            
                            InstructionCard(
                                step: "4",
                                title: "Apply changes",
                                description: "Click \"Apply Selected Changes\" to write the changes to disk. Use \"Undo All\" to revert if needed.",
                                color: .purple
                            )
                        }
                    }
                }
                .padding(20)
                .background(
                    VisualEffectView(material: .contentBackground, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
            }
            .padding(20)
        }
        .background(
            VisualEffectView(material: .windowBackground, blendingMode: .behindWindow)
        )
    }
}

// MARK: - Instruction Card Component

struct InstructionCard: View {
    let step: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(step)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(color)
                    )
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            VisualEffectView(material: .menu, blendingMode: .withinWindow)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
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
    @State private var showXMLFormatSettings = false
    
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
            // Toolbar with option buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Code Map toggle
                    ToggleButton(
                        title: "Code Map",
                        isSelected: appState.clipboardSettings.includeCodeMap,
                        action: {
                            appState.clipboardSettings.includeCodeMap.toggle()
                        }
                    )
                    
                    // XML Format toggle - now shows modal
                    Button {
                        showXMLFormatSettings = true
                    } label: {
                        HStack(spacing: 6) {
                            Text("XML Format")
                                .font(.system(size: 13, weight: .medium))
                            Image(systemName: getXMLFormatIcon())
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(getXMLFormatColor())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        )
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                    
                    // Architect toggle
                    ToggleButton(
                        title: "Architect",
                        isSelected: appState.currentRole == .architect,
                        action: {
                            if appState.currentRole == .architect {
                                appState.currentRole = .none
                            } else {
                                appState.currentRole = .architect
                            }
                        }
                    )
                    
                    // Engineer toggle
                    ToggleButton(
                        title: "Engineer",
                        isSelected: appState.currentRole == .engineer,
                        action: {
                            if appState.currentRole == .engineer {
                                appState.currentRole = .none
                            } else {
                                appState.currentRole = .engineer
                            }
                        }
                    )
                    
                    // Custom prompts
                    ForEach(appState.customRoles) { role in
                        ToggleButton(
                            title: role.name,
                            isSelected: appState.currentRole == .custom(role.name),
                            action: {
                                if appState.currentRole == .custom(role.name) {
                                    appState.currentRole = .none
                                } else {
                                    appState.currentRole = .custom(role.name)
                                }
                            }
                        )
                    }
                    
                    // Add custom prompt button
                    Button {
                        appState.showRolePromptSelector = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 12, weight: .medium))
                            Text("Add Custom")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        )
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .background(
                VisualEffectView(material: .headerView, blendingMode: .withinWindow)
            )
            .overlay(
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 0.5),
                alignment: .bottom
            )
            
            // Instructions section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Instructions")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button {
                        instructionsText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .opacity(instructionsText.isEmpty ? 0 : 1)
                }
                
                // Text editor with glass background
                ZStack(alignment: .topLeading) {
                    VisualEffectView(material: .menu, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    TextEditor(text: $instructionsText)
                        .font(.system(.body))
                        .padding(12)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                    
                    if instructionsText.isEmpty {
                        Text("Enter your instructions for the AI here...")
                            .font(.system(.body))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 120)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 0.5)
            
            // Selected files section
            VStack(spacing: 0) {
                HStack {
                    Text("Selected Files")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // File count and token count display
                    HStack(spacing: 4) {
                        Text("\(appState.selectedFiles.count)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("files,")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text(calculateTotalTokens())
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Menu {
                        Button("Sort by Name") {
                            // Implement sorting by name
                        }
                        Button("Sort by Size") {
                            // Implement sorting by size
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Sort")
                                .font(.system(size: 13))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.secondary)
                    }
                    .menuStyle(.borderlessButton)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 0.5)
                
                // Scrollable file area
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if appState.fileViewMode == .folder {
                            // Directory view
                            ForEach(Array(groupFilesByDirectory().keys.sorted()), id: \.self) { directory in
                                if let files = groupFilesByDirectory()[directory] {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(directory)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 20)
                                            
                                            Spacer()
                                        }
                                        
                                        LazyVGrid(columns: [
                                            GridItem(.flexible(), spacing: 12),
                                            GridItem(.flexible(), spacing: 12)
                                        ], spacing: 12) {
                                            ForEach(files) { file in
                                                ModernFileItemView(file: file)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        } else {
                            // File list view
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(selectedFiles) { file in
                                    ModernFileItemView(file: file)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .frame(maxHeight: .infinity)
            }
            .background(
                VisualEffectView(material: .contentBackground, blendingMode: .withinWindow)
            )
            
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 0.5)
            
            // Copy to clipboard section at the bottom
            VStack(spacing: 12) {
                // Selected components pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if appState.clipboardSettings.includeInstructions {
                            ModernPill(text: "Instructions", color: .blue)
                        }
                        
                        if appState.currentRole != .none {
                            ModernPill(text: "Role: \(appState.currentRole.displayName)", color: .purple)
                        }
                        
                        if appState.clipboardSettings.includeCodeMap {
                            ModernPill(text: "Code Map", color: .green)
                        }
                        
                        if appState.clipboardSettings.includeFiles {
                            ModernPill(text: "Files", color: .orange)
                        }
                        
                        if appState.formatOption != .none {
                            ModernPill(text: "XML Format: \(appState.formatOption == .diff ? "Diff" : "Whole")", color: .indigo)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                HStack(spacing: 12) {
                    // Copy button
                    Button {
                        appState.copyFormattedContentToClipboard()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14, weight: .medium))
                            Text("Copy to Clipboard")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        )
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Clipboard settings button
                    Button {
                        showClipboardSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 44, height: 44)
                            .background(
                                VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            )
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Total token count for copy
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Total Tokens")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(calculateTotalForCopy())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .background(
                VisualEffectView(material: .headerView, blendingMode: .withinWindow)
            )
        }
        .sheet(isPresented: $showClipboardSettings) {
            ClipboardSettingsView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showXMLFormatSettings) {
            ModernSettingsView()
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

// MARK: - Modern UI Components

struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .green : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                VisualEffectView(
                    material: isSelected ? .selection : .menu,
                    blendingMode: .withinWindow
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }
}

struct ModernPill: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                VisualEffectView(material: .menu, blendingMode: .withinWindow)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
}

struct ModernFileItemView: View {
    let file: SelectedFile
    @State private var isHovering: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                
                Text(file.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack {
                Text(file.size)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(String(format: "%.1f%%", file.percentage))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 3)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.green)
                    .frame(width: max(CGFloat(file.percentage / 100.0) * 120, 3), height: 3)
            }
            .frame(maxWidth: 120)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            VisualEffectView(
                material: isHovering ? .selection : .menu,
                blendingMode: .withinWindow
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(isHovering ? 0.8 : 0.6)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
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

struct ModernSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("XML Format Settings")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Choose how your code should be formatted when copying to clipboard.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(
                VisualEffectView(material: .headerView, blendingMode: .withinWindow)
            )
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Format options
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Format")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            // Diff option
                            Button {
                                appState.formatOption = .diff
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: appState.formatOption == .diff ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(appState.formatOption == .diff ? .blue : .secondary)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Diff")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Outputs only the specific changes needed. Requires a powerful model (e.g. Claude Sonnet).")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(
                                    VisualEffectView(
                                        material: appState.formatOption == .diff ? .selection : .menu,
                                        blendingMode: .withinWindow
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(appState.formatOption == .diff ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // Whole option
                            Button {
                                appState.formatOption = .whole
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: appState.formatOption == .whole ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(appState.formatOption == .whole ? .green : .secondary)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Whole")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Outputs entire file contents with changes. Works with any model.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(
                                    VisualEffectView(
                                        material: appState.formatOption == .whole ? .selection : .menu,
                                        blendingMode: .withinWindow
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(appState.formatOption == .whole ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Information section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("When you choose XML Diff format:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(
                                number: "1",
                                text: "Each file is wrapped in XML tags <file path=\"path/to/file.ext\">...</file>",
                                color: .blue
                            )
                            
                            InfoRow(
                                number: "2",
                                text: "The AI can easily parse these tags to understand file structure",
                                color: .green
                            )
                            
                            InfoRow(
                                number: "3",
                                text: "This format works best for code changes across multiple files",
                                color: .orange
                            )
                        }
                    }
                }
                .padding(24)
            }
            .background(
                VisualEffectView(material: .contentBackground, blendingMode: .withinWindow)
            )
            
            // Footer buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                } 
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    VisualEffectView(material: .menu, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                )
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
                
                Spacer()
                
                Button("Apply") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    VisualEffectView(material: .menu, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                )
                .foregroundColor(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(
                VisualEffectView(material: .headerView, blendingMode: .withinWindow)
            )
        }
        .frame(width: 500, height: 600)
        .background(
            VisualEffectView(material: .windowBackground, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let number: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(
                    Circle()
                        .fill(color)
                )
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            VisualEffectView(material: .menu, blendingMode: .withinWindow)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .opacity(0.6)
        )
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
// ... existing code ...