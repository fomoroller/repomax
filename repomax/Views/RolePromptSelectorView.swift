import SwiftUI
import AppKit

struct RolePromptSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var showAddCustomPrompt = false
    @State private var customPromptName = ""
    @State private var customPromptContent = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Prompt Template")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choose a pre-defined role or create your own custom prompt")
                .foregroundColor(.gray)
            
            // Built-in roles
            VStack(alignment: .leading, spacing: 12) {
                Text("Built-in Roles")
                    .font(.headline)
                
                Button {
                    appState.currentRole = .architect
                    appState.useArchitectPrompt()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text("[Architect]")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button {
                    appState.currentRole = .engineer
                    appState.useEngineerPrompt()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text("[Engineer]")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Custom roles
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Custom Prompts")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        showAddCustomPrompt = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New")
                        }
                        .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
                
                if appState.customRoles.isEmpty {
                    Text("No custom prompts yet. Create one with the 'Add New' button.")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(appState.customRoles) { role in
                        Button {
                            appState.currentRole = .custom(role.name)
                            appState.instructionsText = role.prompt
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Text("[\(role.name)]")
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Spacer()
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(width: 500, height: 550)
        .sheet(isPresented: $showAddCustomPrompt) {
            // Add custom prompt sheet
            VStack(alignment: .leading, spacing: 16) {
                Text("Create Custom Prompt")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TextField("Prompt Name", text: $customPromptName)
                    .padding(8)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(6)
                
                Text("Prompt Content")
                    .font(.headline)
                
                TextEditor(text: $customPromptContent)
                    .font(.system(.body, design: .monospaced))
                    .padding(4)
                    .frame(height: 200)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(6)
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        customPromptName = ""
                        customPromptContent = ""
                        showAddCustomPrompt = false
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Save") {
                        if !customPromptName.isEmpty && !customPromptContent.isEmpty {
                            let newRole = AppState.CustomRole(name: customPromptName, prompt: customPromptContent)
                            appState.customRoles.append(newRole)
                            customPromptName = ""
                            customPromptContent = ""
                            showAddCustomPrompt = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(customPromptName.isEmpty || customPromptContent.isEmpty)
                }
            }
            .padding()
            .frame(width: 500, height: 400)
        }
    }
}