import Foundation

enum WidgetIdentity {
    static let group = "group.com.neonreels.puzzle"
    static let kind = "com.neonreels.puzzle.progress"
    static let scheme = "neonreels"
    static let route = "puzzle"
    static let displayName = "Neon Reels"
    static let emptyHint = "Enter the puzzle hall to begin."
    static let widgetName = "Next bright idea"
    static let widgetDescription = "Continue your puzzle and track completed levels."
    static let icon = "sparkles"
    static let theme = "reels"
    static let accent: [Double] = [1, 0.81, 0.36]
    static let background: [Double] = [0.12, 0.04, 0.23]
    static let serif = false
    static var url: URL { URL(string: "\(scheme)://widget/\(route)")! }
    static func accepts(_ url: URL) -> Bool { url.scheme == scheme && url.host == "widget" && url.path == "/" + route }
}
