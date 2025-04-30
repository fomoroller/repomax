import Foundation

struct GitignoreParser {
    private var patterns: [String] = []
    
    init(gitignoreContent: String) {
        // Split by newlines, filter out comments, etc.
        self.patterns = gitignoreContent
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }
    }
    
    func isIgnored(filePath: String) -> Bool {
        // Simple matching logic or use more advanced glob/regex
        // For demonstration, we just do a naive contains check:
        for pattern in patterns {
            if filePath.contains(pattern) {
                return true
            }
        }
        return false
    }
}