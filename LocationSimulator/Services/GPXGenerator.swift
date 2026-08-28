import CoreLocation
import Foundation

enum GPXGenerationError: LocalizedError {
    case invalidCoordinate
    case writeFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidCoordinate:
            return "The selected coordinate is not a valid location on Earth, so a GPX file cannot be generated."
        case .writeFailed(let underlying):
            return "The GPX file could not be written: \(underlying.localizedDescription)"
        }
    }
}

/// Generates GPX documents that Xcode understands for location simulation.
///
/// A GPX file with a single `<wpt>` element makes Xcode simulate a fixed
/// position. A file with multiple `<wpt>` elements makes Xcode move the
/// simulated location along the waypoints, using each waypoint's `<time>`
/// element (when present) to derive the movement speed.
enum GPXGenerator {
    struct Waypoint {
        var coordinate: CLLocationCoordinate2D
        var name: String?
        var time: Date?
    }

    private static let posixLocale = Locale(identifier: "en_US_POSIX")

    /// Builds a GPX 1.1 document for a single fixed coordinate.
    static func document(for coordinate: CLLocationCoordinate2D, name: String) throws -> String {
        try document(for: [Waypoint(coordinate: coordinate, name: name, time: nil)])
    }

    /// Builds a GPX 1.1 document for one or more waypoints.
    static func document(for waypoints: [Waypoint]) throws -> String {
        guard !waypoints.isEmpty,
              waypoints.allSatisfy({ CLLocationCoordinate2DIsValid($0.coordinate) }) else {
            throw GPXGenerationError.invalidCoordinate
        }

        var lines: [String] = []
        lines.append(#"<?xml version="1.0" encoding="UTF-8"?>"#)
        lines.append(#"<gpx version="1.1" creator="LocationSimulator" xmlns="http://www.topografix.com/GPX/1/1">"#)
        for waypoint in waypoints {
            let lat = format(waypoint.coordinate.latitude)
            let lon = format(waypoint.coordinate.longitude)
            lines.append(#"    <wpt lat="\#(lat)" lon="\#(lon)">"#)
            if let name = waypoint.name, !name.isEmpty {
                lines.append("        <name>\(xmlEscaped(name))</name>")
            }
            if let time = waypoint.time {
                lines.append("        <time>\(iso8601Formatter.string(from: time))</time>")
            }
            lines.append("    </wpt>")
        }
        lines.append("</gpx>")
        return lines.joined(separator: "\n") + "\n"
    }

    /// Writes a single-waypoint GPX file into the temporary directory and
    /// returns its URL, ready to hand to a `ShareLink`.
    static func writeFile(for coordinate: CLLocationCoordinate2D, name: String) throws -> URL {
        let contents = try document(for: coordinate, name: name)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(sanitizedFileName(from: name))
            .appendingPathExtension("gpx")
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            throw GPXGenerationError.writeFailed(underlying: error)
        }
    }

    // MARK: - Helpers

    private static func format(_ value: Double) -> String {
        String(format: "%.6f", locale: posixLocale, value)
    }

    private static var iso8601Formatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }

    private static func xmlEscaped(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    private static func sanitizedFileName(from name: String) -> String {
        let allowed = CharacterSet.alphanumerics
        var result = ""
        var lastWasDash = false
        for scalar in name.unicodeScalars {
            if allowed.contains(scalar) {
                result.unicodeScalars.append(scalar)
                lastWasDash = false
            } else if !lastWasDash && !result.isEmpty {
                result.append("-")
                lastWasDash = true
            }
        }
        if result.hasSuffix("-") { result.removeLast() }
        return result.isEmpty ? "SimulatedLocation" : result
    }
}
