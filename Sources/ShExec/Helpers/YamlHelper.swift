import Foundation

enum YamlHelper {
    static func encode(_ dictionary: [String: Any]) -> String {
        var yaml = ""
        for (key, value) in dictionary {
            yaml += "\(key): \(formatYAMLValue(value))\n"
        }
        return yaml
    }

    static func decode(_ yaml: String) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        let lines = yaml.split(separator: "\n")
        for line in lines {
            let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count == 2 {
                dictionary[parts[0]] = parseYAMLValue(parts[1])
            }
        }
        return dictionary
    }

    private static func formatYAMLValue(_ value: Any) -> String {
        switch value {
        case let str as String:
            return str.contains(":") ? "\"\(str)\"" : str
        case let dict as [String: Any]:
            return "{ " + dict.map { "\($0.key): \($0.value)" }.joined(separator: ", ") + " }"
        default:
            return "\(value)"
        }
    }

    private static func parseYAMLValue(_ value: String) -> Any {
        if let intValue = Int(value) {
            return intValue
        } else if let doubleValue = Double(value) {
            return doubleValue
        } else if value.lowercased() == "true" || value.lowercased() == "false" {
            return Bool(value.lowercased()) ?? value
        } else {
            return value
        }
    }
}
