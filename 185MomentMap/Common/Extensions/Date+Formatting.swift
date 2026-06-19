import Foundation

extension Date {
    func startOfDay(calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }

    func formatted(pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }
}

extension Memory {
    var shareText: String {
        var lines = [
            title,
            "Date: \(date.formatted(pattern: "dd MMM yyyy"))",
            "Mood: \(mood.rawValue) \(mood.displayName)"
        ]
        if !tags.isEmpty {
            lines.append("Tags: \(tags.map(\.displayName).joined(separator: ", "))")
        }
        if let address, !address.isEmpty {
            lines.append("Address: \(address)")
        }
        lines.append("Coordinates: \(String(format: "%.5f", latitude)), \(String(format: "%.5f", longitude))")
        if let note, !note.isEmpty {
            lines.append("Note: \(note)")
        }
        return lines.joined(separator: "\n")
    }

    var cityName: String? {
        guard let address, !address.isEmpty else { return nil }
        return address.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? address
    }
}
