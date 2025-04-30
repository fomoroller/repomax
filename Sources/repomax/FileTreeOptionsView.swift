import SwiftUI

@available(macOS 10.15, *)
struct FileTreeOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedOption = "Selected"
    @State private var includeRootsWithSelectedFiles = true
    @State private var codeMapUsage = "Auto"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("File Tree")
                .font(.headline)
                .padding(.bottom, 8)
            
            HStack {
                Button("Auto") {
                    selectedOption = "Auto"
                }
                .frame(maxWidth: .infinity)
                .background(selectedOption == "Auto" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button("Files") {
                    selectedOption = "Files"
                }
                .frame(maxWidth: .infinity)
                .background(selectedOption == "Files" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button("Selected") {
                    selectedOption = "Selected"
                }
                .frame(maxWidth: .infinity)
                .background(selectedOption == "Selected" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.bottom, 16)
            
            Toggle("Include roots with selected files", isOn: $includeRootsWithSelectedFiles)
                .toggleStyle(CheckboxToggleStyle())
                .padding(.bottom, 8)
            
            Text("Code Map")
                .font(.headline)
                .padding(.bottom, 8)
            
            HStack {
                Button("Auto") {
                    codeMapUsage = "Auto"
                }
                .frame(maxWidth: .infinity)
                .background(codeMapUsage == "Auto" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button("Always") {
                    codeMapUsage = "Always"
                }
                .frame(maxWidth: .infinity)
                .background(codeMapUsage == "Always" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button("Never") {
                    codeMapUsage = "Never"
                }
                .frame(maxWidth: .infinity)
                .background(codeMapUsage == "Never" ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 400)
    }
}

@available(macOS 10.15, *)
struct CheckboxToggleStyle: ToggleStyle {
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
            
            AnyView(configuration.label)
        }
    }
}