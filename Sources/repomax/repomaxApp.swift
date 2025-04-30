import SwiftUI

@main
struct repomaxApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Project") {
                    appState.createNewProject()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}