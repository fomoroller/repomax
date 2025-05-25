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
    
    func isIgnored(filePath: String, relativeTo basePath: String = "") -> Bool {
        // Convert absolute path to relative if needed
        let relativePath: String
        if !basePath.isEmpty && filePath.hasPrefix(basePath) {
            relativePath = String(filePath.dropFirst(basePath.count + 1))
        } else {
            relativePath = filePath
        }
        
        // Check each pattern
        for pattern in patterns {
            let isMatch = matchesPattern(pattern: pattern, path: relativePath)
            if isMatch {
                // Debug: log successful matches
                if relativePath.contains("node_modules") {
                    print("MATCH: Pattern '\(pattern)' matched path '\(relativePath)'")
                }
                return true
            } else {
                // Debug: log failed matches for node_modules paths
                if relativePath.contains("node_modules") {
                    print("NO MATCH: Pattern '\(pattern)' did not match path '\(relativePath)'")
                }
            }
        }
        return false
    }
    
    private func matchesPattern(pattern: String, path: String) -> Bool {
        // Handle negation patterns (starting with !)
        if pattern.hasPrefix("!") {
            let negatedPattern = String(pattern.dropFirst())
            return !matchesGlobPattern(pattern: negatedPattern, path: path)
        }
        
        return matchesGlobPattern(pattern: pattern, path: path)
    }
    
    private func matchesGlobPattern(pattern: String, path: String) -> Bool {
        // Handle different types of patterns in the correct order
        
        // First check for absolute patterns (starting with /)
        if pattern.hasPrefix("/") {
            let absolutePattern = String(pattern.dropFirst())
            
            // If the absolute pattern also ends with /, it's an absolute directory pattern
            if absolutePattern.hasSuffix("/") {
                let dirPattern = String(absolutePattern.dropLast())
                // For absolute directory patterns, check if the path matches the pattern
                // and ensure we're checking against a directory (either the path itself or its parent)
                
                // Check if the full path matches the directory pattern
                if globMatch(pattern: dirPattern, string: path) {
                    return true
                }
                
                // Also check if the parent directory of a file matches
                let parentPath = (path as NSString).deletingLastPathComponent
                if !parentPath.isEmpty && globMatch(pattern: dirPattern, string: parentPath) {
                    return true
                }
                
                return false
            } else {
                // Regular absolute pattern
                return globMatch(pattern: absolutePattern, string: path)
            }
        }
        
        // Then check for directory patterns (ending with /) that are not absolute
        if pattern.hasSuffix("/") {
            let dirPattern = String(pattern.dropLast())
            let pathComponents = path.components(separatedBy: "/")
            
            // Check if any directory in the path matches
            for component in pathComponents {
                if globMatch(pattern: dirPattern, string: component) {
                    return true
                }
            }
            
            // Also check if the full path matches (for cases like "frontend/")
            if globMatch(pattern: dirPattern, string: path) {
                return true
            }
            
            return false
        }
        
        // Patterns with ** (match any number of directories)
        if pattern.contains("**/") {
            return matchesDoubleStarPattern(pattern: pattern, path: path)
        }
        
        // Simple patterns - check if file name matches or if pattern matches any part of path
        let fileName = (path as NSString).lastPathComponent
        let pathComponents = path.components(separatedBy: "/")
        
        // Check if pattern matches the filename
        if globMatch(pattern: pattern, string: fileName) {
            return true
        }
        
        // Check if pattern matches any path component
        for component in pathComponents {
            if globMatch(pattern: pattern, string: component) {
                return true
            }
        }
        
        // Check if pattern matches the full relative path
        return globMatch(pattern: pattern, string: path)
    }
    
    private func matchesDoubleStarPattern(pattern: String, path: String) -> Bool {
        // Split pattern by **
        let parts = pattern.components(separatedBy: "**/")
        
        if parts.count == 1 {
            // No ** in pattern, treat as regular pattern
            return globMatch(pattern: pattern, string: path)
        }
        
        // For patterns like **/node_modules or **/node_modules/**
        let prefix = parts.first ?? ""
        let suffix = parts.dropFirst().joined(separator: "**/")
        
        // If there's no prefix, just match the suffix anywhere in the path
        if prefix.isEmpty {
            let pathComponents = path.components(separatedBy: "/")
            for i in 0..<pathComponents.count {
                let subPath = pathComponents[i...].joined(separator: "/")
                if globMatch(pattern: suffix, string: subPath) {
                    return true
                }
            }
            return false
        }
        
        // If there's a prefix, it must match the beginning
        let pathComponents = path.components(separatedBy: "/")
        
        for i in 0..<pathComponents.count {
            let prefixPath = pathComponents[0...i].joined(separator: "/")
            if globMatch(pattern: prefix, string: prefixPath) {
                // Check if remaining path matches suffix
                if i + 1 < pathComponents.count {
                    let remainingPath = pathComponents[(i + 1)...].joined(separator: "/")
                    if suffix.isEmpty || globMatch(pattern: suffix, string: remainingPath) {
                        return true
                    }
                } else if suffix.isEmpty {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func globMatch(pattern: String, string: String) -> Bool {
        // Simple glob matching with * and ? wildcards
        let regexPattern = pattern
            .replacingOccurrences(of: ".", with: "\\.")
            .replacingOccurrences(of: "*", with: ".*")
            .replacingOccurrences(of: "?", with: ".")
        
        do {
            let regex = try NSRegularExpression(pattern: "^" + regexPattern + "$", options: [])
            let range = NSRange(location: 0, length: string.utf16.count)
            return regex.firstMatch(in: string, options: [], range: range) != nil
        } catch {
            // Fallback to simple string matching if regex fails
            return string == pattern
        }
    }
}