import Foundation

enum TerminalHelper {
    enum ANSIColor: String {
        case black = "\u{001B}[0;30m"
        case red = "\u{001B}[0;31m"
        case green = "\u{001B}[0;32m"
        case yellow = "\u{001B}[0;33m"
        case blue = "\u{001B}[0;34m"
        case magenta = "\u{001B}[0;35m"
        case cyan = "\u{001B}[0;36m"
        case white = "\u{001B}[0;37m"
        case reset = "\u{001B}[0m"
        case teal = "\u{001B}[38;5;6m"
    }

    enum TextStyle {
        case normal
        case bold
    }

    static func doesTerminalSupportANSIColors() -> Bool {
        guard isatty(fileno(stdout)) != 0 else {
            return false
        }

        if let termType = getenv("TERM"), let term = String(utf8String: termType) {
            let supportingTerms = ["xterm-color", "xterm-256color", "screen", "screen-256color", "ansi", "linux", "vt100"]
            return supportingTerms.contains(where: term.contains)
        }

        return false
    }

    static func printInColors(_ message: String, color: ANSIColor = .blue, style: TextStyle = .bold) {
        if doesTerminalSupportANSIColors() {
            let styleCode = style == .bold ? ";1m" : "m"
            let coloredMessage =
                "\(color.rawValue)\(style == .bold ? color.rawValue.replacingOccurrences(of: "[0;", with: "[1;") : color.rawValue)\(message)\(ANSIColor.reset.rawValue)"
            print(coloredMessage)
        } else {
            print(message)
        }
    }
}
