import SwiftUI

// Duplicate CheckboxToggleStyle for this file
struct ClipboardCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.gray, lineWidth: 1)
                    .background(
                        configuration.isOn ? 
                        RoundedRectangle(cornerRadius: 3).fill(Color.yellow) : 
                        RoundedRectangle(cornerRadius: 3).fill(Color.clear)
                    )
                    .frame(width: 16, height: 16)
                
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
            
            configuration.label
        }
    }
}

struct ClipboardSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clipboard Settings")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Hotkey ⌘ + ⌥ + c to copy")
                .foregroundColor(.gray)
                .padding(.bottom, 8)
            
            // Content settings
            Group {
                Toggle("Include Instructions", isOn: $appState.clipboardSettings.includeInstructions)
                    .toggleStyle(ClipboardCheckboxToggleStyle())
                
                Toggle("Include Files", isOn: $appState.clipboardSettings.includeFiles)
                    .toggleStyle(ClipboardCheckboxToggleStyle())
                
                Toggle("Include Code Map", isOn: $appState.clipboardSettings.includeCodeMap)
                    .toggleStyle(ClipboardCheckboxToggleStyle())
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Copy Now") {
                    appState.copyFormattedContentToClipboard()
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 350, height: 200)
    }
}