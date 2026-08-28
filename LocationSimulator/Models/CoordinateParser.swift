import CoreLocation
import Foundation

enum CoordinateInputError: LocalizedError {
    case emptyLatitude
    case emptyLongitude
    case malformedLatitude(String)
    case malformedLongitude(String)
    case latitudeOutOfRange(Double)
    case longitudeOutOfRange(Double)

    var errorDescription: String? {
        switch self {
        case .emptyLatitude:
            return "Latitude is empty. Enter a value between -90 and 90."
        case .emptyLongitude:
            return "Longitude is empty. Enter a value between -180 and 180."
        case .malformedLatitude(let text):
            return "“\(text)” is not a valid latitude. Use decimal degrees, for example 25.2048."
        case .malformedLongitude(let text):
            return "“\(text)” is not a valid longitude. Use decimal degrees, for example 55.2708."
        case .latitudeOutOfRange(let value):
            return "Latitude \(value) is out of range. It must be between -90 and 90."
        case .longitudeOutOfRange(let value):
            return "Longitude \(value) is out of range. It must be between -180 and 180."
        }
    }
}

/// Parses and validates user-typed latitude/longitude strings.
enum CoordinateParser {
    static func parse(latitude: String, longitude: String) throws -> CLLocationCoordinate2D {
        let lat = try parseLatitude(latitude)
        let lon = try parseLongitude(longitude)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    static func parseLatitude(_ text: String) throws -> Double {
        let normalized = normalize(text)
        guard !normalized.isEmpty else { throw CoordinateInputError.emptyLatitude }
        guard let value = Double(normalized), value.isFinite else {
            throw CoordinateInputError.malformedLatitude(text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        guard (-90.0...90.0).contains(value) else {
            throw CoordinateInputError.latitudeOutOfRange(value)
        }
        return value
    }

    static func parseLongitude(_ text: String) throws -> Double {
        let normalized = normalize(text)
        guard !normalized.isEmpty else { throw CoordinateInputError.emptyLongitude }
        guard let value = Double(normalized), value.isFinite else {
            throw CoordinateInputError.malformedLongitude(text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        guard (-180.0...180.0).contains(value) else {
            throw CoordinateInputError.longitudeOutOfRange(value)
        }
        return value
    }

    /// Trims whitespace and accepts a decimal comma (e.g. "25,2048") as a decimal point.
    private static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
    }
}
