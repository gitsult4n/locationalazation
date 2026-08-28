import CoreLocation
import Foundation
import SwiftData

/// A user-saved location, persisted locally with SwiftData.
@Model
final class SavedLocation {
    var name: String
    var latitude: Double
    var longitude: Double
    var createdAt: Date

    init(name: String, latitude: Double, longitude: Double, createdAt: Date = .now) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
