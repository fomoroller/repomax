import SwiftUI

@available(macOS 10.15, *)
struct MergeModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var selectedChanges: Set<String> = []
    
    var body: some View {
        VStack {
            List(getMergeFileChanges(), id: \.path) { change in
                FileChangeRowView(
                    change: change,
                    isSelected: selectedChanges.contains(change.path)
                )
                .onTapGesture {
                    if selectedChanges.contains(change.path) {
                        selectedChanges.remove(change.path)
                    } else {
                        selectedChanges.insert(change.path)
                    }
                }
            }
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                Spacer()
                
                Button("Apply Changes") {
                    // Handle applying changes
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 600, height: 400)
    }
    
    private func getMergeFileChanges() -> [MergeFileChange] {
        return appState.pendingChanges.map { change in
            MergeFileChange(
                fileName: change.fileName,
                path: change.filePath,
                changeType: convertChangeType(change.changeType),
                content: change.newContent
            )
        }
    }
    
    private func convertChangeType(_ type: FileChange.ChangeType) -> MergeFileChange.ChangeType {
        switch type {
        case .create:
            return .create
        case .modify, .rewrite:
            return .modify
        case .delete:
            return .delete
        }
    }
}

@available(macOS 10.15, *)
struct FileChangeRowView: View {
    let change: MergeFileChange
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Checkbox for selection
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.gray, lineWidth: 1)
                    .background(
                        isSelected ? 
                        RoundedRectangle(cornerRadius: 3).fill(Color.yellow) : 
                        RoundedRectangle(cornerRadius: 3).fill(Color.clear)
                    )
                    .frame(width: 16, height: 16)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            
            // File icon based on type
            Image(systemName: "doc")
                .foregroundColor(
                    change.changeType == .create ? .green :
                        change.changeType == .modify ? .yellow :
                        change.changeType == .delete ? .red :
                        .blue
                )
            
            // File name and change type
            VStack(alignment: .leading, spacing: 2) {
                Text(change.fileName)
                    .font(.system(size: 14))
                    .lineLimit(1)
                
                Text(change.changeType.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(
                        change.changeType == .create ? .green :
                            change.changeType == .modify ? .yellow :
                            change.changeType == .delete ? .red :
                            .blue
                    )
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(4)
    }
}

@available(macOS 10.15, *)
struct CodeView: View {
    let content: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(content)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.black.opacity(0.1))
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MergeFileChange {
    let fileName: String
    let path: String
    let changeType: ChangeType
    let content: String
    
    enum ChangeType: String {
        case create = "Created"
        case modify = "Modified"
        case delete = "Deleted"
    }
}